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
}

public class SensorManager: ISensorManager {
    public let sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)
    public let altimeterPublisher: CurrentValueSubject<AltitudeSensorData?, SensorError> = .init(nil)

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
      guard motion.isDeviceMotionAvailable else {
          throw SensorError.sensorNotAvaliable
      }

      if self.motion.isDeviceMotionActive {
          return
      }

      motion.startDeviceMotionUpdates(to: sensorOperation) { (data, error) in
          guard let data = data else {
              if error != nil {
                  self.sensorPublisher.send(completion: .failure(SensorError.noData))
              }
              return
          }
          self.sensorPublisher.send(MotionSensorData(data: data))
      }
    }

    public func startAltimeter() throws {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { throw SensorError.sensorNotAvaliable }

        altimeter.startRelativeAltitudeUpdates(to: .main) { (data, error) in
            guard let data = data else {
                if let error = error {
                    Logger().log(message: "Altimeter error \(error.localizedDescription)")
                    self.stopAltimeter()
                }
                return
            }

            let timestampSensor = Int(data.timestamp * 1000)
            let timestampLocal = Int(Date().timeIntervalSince1970 * 1000)
            self.altimeterPublisher.send(AltitudeSensorData(timestampSensor: timestampSensor, timestampLocal: timestampLocal, altitudenData: [Double(truncating: data.relativeAltitude)]))
        }
    }
    
    public func stop() {
        sensorOperation.underlyingQueue?.async {
            self.stopMotion()
            self.stopAltimeter()
        }
    }

    public func stopMotion() {
      self.motion.stopDeviceMotionUpdates()
    }

    public func stopAltimeter() {
        self.altimeter.stopRelativeAltitudeUpdates()
    }
}
#endif
