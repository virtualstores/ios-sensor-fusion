// SensorManager
// VSSensorFusion
//
// Created by CJ on 2021-11-26
// Copyright Virtual Stores - 2021
//
import Foundation
import VSFoundation
import CoreMotion

public class SensorManager: ISensorManager {

    private let INTERVAL100Hz = 1.0 / 100.0
    private let GRAVITY = 9.81

    private let motion: CMMotionManager
    private let sensorOperation = OperationQueue()
    private let serialDispatch = DispatchQueue(label: "se.tt2.sensorManager")

    private var isRunning = false

    private var delegates = [String:ISensorManagerDelegate]()

    public init() {
        self.motion = CMMotionManager()
        self.motion.deviceMotionUpdateInterval = INTERVAL100Hz
    }

    public func start() {
        if self.isRunning {
            return
        }

        self.isRunning = true

        if self.motion.isDeviceMotionAvailable {
            self.motion.startDeviceMotionUpdates(to: self.sensorOperation) { [self] (data, _) in
                if let validData = data {

                    let timestampSensor = Int(validData.timestamp * 1000)
                    let timestampLocal = Int(Date().timeIntervalSince1970 * 1000)

                    var accelerationData: [Float] = [Float](repeating: 0, count: 3)
                    accelerationData[0] = Float(validData.userAcceleration.x * GRAVITY)
                    accelerationData[1] = Float(validData.userAcceleration.y * GRAVITY)
                    accelerationData[2] = Float(validData.userAcceleration.z * GRAVITY)

                    var gravityData: [Float] = [Float](repeating: 0, count: 3)
                    gravityData[0] = Float(validData.gravity.x * -GRAVITY)
                    gravityData[1] = Float(validData.gravity.y * -GRAVITY)
                    gravityData[2] = Float(validData.gravity.z * -GRAVITY)

                    var rotationData: [Float] = [Float](repeating: 0, count: 4)
                    rotationData[0] = Float(validData.attitude.quaternion.x)
                    rotationData[1] = Float(validData.attitude.quaternion.y)
                    rotationData[2] = Float(validData.attitude.quaternion.z)
                    rotationData[3] = Float(validData.attitude.quaternion.w)

                    self.notifyMotionSensorDataUpdate(
                        data: MotionSensorData(
                            timestampSensor: timestampSensor,
                            timestampLocal: timestampLocal,
                            accelerationData: accelerationData,
                            gravityData: gravityData,
                            rotationData: rotationData
                        )
                    )
                }
            }
        }
    }

    private func notifyMotionSensorDataUpdate(data: MotionSensorData) {
        delegates.forEach { $1.onNewMotionSensorData(data: data) }
    }

    public func stop() {
        self.motion.stopDeviceMotionUpdates()
        self.isRunning = false
    }

    public func add(delegate: ISensorManagerDelegate) {
        delegates[delegate.id] = delegate
    }

    public func remove(delegate: ISensorManagerDelegate) {
        delegates.removeValue(forKey: delegate.id)
    }
}
