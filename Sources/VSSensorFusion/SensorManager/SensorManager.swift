//
// SensorManager
// VSSensorFusion
//
// Created by Karl Söderberg on 2021-12-05
// Copyright Virtual Stores - 2021
//
#if os(iOS)
import Foundation
import VSFoundation
import CoreMotion
import Combine

public extension TimeInterval {
    static var interval100Hz = 0.01
    static var interval200Hz = 0.005
}

public class SensorManager: ISensorManager {
    public let sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)
    public static let sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)
    public let altimeterPublisher: CurrentValueSubject<AltitudeSensorData?, SensorError> = .init(nil)

    private let accelerometerPublisher: CurrentValueSubject<CMAccelerometerData?, SensorError> = .init(nil)
    private let magnetometerPublisher: CurrentValueSubject<CMMagnetometerData?, SensorError> = .init(nil)

    private let motion = CMMotionManager()
    private let sensorOperation = OperationQueue()
    private let altimeter = CMAltimeter()

    public var isRunning: Bool { motion.isDeviceMotionActive }

    public init(updateInterval: TimeInterval) {
        self.motion.deviceMotionUpdateInterval = updateInterval
    }
    
    public convenience init() {
        self.init(updateInterval: .interval100Hz)
    }

    public func start() throws {
        try startMotion()
        try startAltimeter()
    }

    public func startMotion() throws {
        guard motion.isDeviceMotionAvailable else { throw SensorError.sensorNotAvaliable }
        guard !motion.isDeviceMotionActive else { return }

        motion.startDeviceMotionUpdates(to: sensorOperation) { (data, error) in
            guard let data = data else {
                if error != nil {
                    self.sensorPublisher.send(completion: .failure(.noData))
                }
                return
            }
            let motionData = MotionSensorData(data: data, accelerometerData: self.accelerometerPublisher.value, magnetometerData: self.magnetometerPublisher.value)
            self.sensorPublisher.send(motionData)
            SensorManager.sensorPublisher.send(motionData)
        }

        if motion.isAccelerometerAvailable {
            motion.accelerometerUpdateInterval = .interval100Hz
            motion.startAccelerometerUpdates(to: sensorOperation) { (data, error) in
                guard let data = data else {
                    if error != nil {
                        self.sensorPublisher.send(completion: .failure(.noData))
                    }
                    return
                }
                self.accelerometerPublisher.send(data)
            }
        }

        if motion.isMagnetometerAvailable {
            motion.magnetometerUpdateInterval = .interval100Hz
            motion.startMagnetometerUpdates(to: sensorOperation) { (data, error) in
                guard let data = data else {
                    if error != nil {
                        self.sensorPublisher.send(completion: .failure(.noData))
                    }
                    return
                }
                self.magnetometerPublisher.send(data)
            }
        }
    }

    var isAltimeterActive = false
    public func startAltimeter() throws {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { throw SensorError.sensorNotAvaliable }
        isAltimeterActive = true
        altimeter.startRelativeAltitudeUpdates(to: sensorOperation) { (data, error) in
            guard let data = data else {
                if let error = error {
                    Logger().log(message: "Altimeter error \(error.localizedDescription)")
                    self.stopAltimeter()
                }
                return
            }

            self.altimeterPublisher.send(AltitudeSensorData(
              timestampSensor: Int(data.timestamp * 1000),
              timestampLocal: Date().currentTimeMillis,
              timestampLocalNano: .nanoTime,
              altitudeData: [data.relativeAltitude.doubleValue],
              barometerData: [data.pressure.doubleValue],
              cmAltitude: data
            ))
        }
    }
    
    public func stop() {
        sensorOperation.underlyingQueue?.async {
            self.stopMotion()
            self.stopAltimeter()
        }
    }

    public func stopMotion() {
        motion.stopDeviceMotionUpdates()
    }

    public func stopAltimeter() {
        guard isAltimeterActive else { return }
        isAltimeterActive = false
        altimeter.stopRelativeAltitudeUpdates()
    }
}
#endif
