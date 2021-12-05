// SensorManagerModern
// VSSensorFusion
//
// Created by Karl Söderberg on 2021-12-05
// Copyright Virtual Stores - 2021
//

import Foundation
import VSFoundation
import CoreMotion
import Combine

public extension TimeInterval {
    static var interval100Hz = 0.01
}

public class SensorManagerModern: ISensorManagerModern {
    
    public var sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)

    private let motion = CMMotionManager()
    private let sensorOperation = OperationQueue()

    public var isRunning: Bool { motion.isDeviceMotionActive }

    public init(updateInterval: TimeInterval) {
        self.motion.deviceMotionUpdateInterval = updateInterval
    }
    
    public convenience init() {
        self.init(updateInterval: .interval100Hz)
    }

    public func start() throws {
        guard motion.isDeviceMotionAvailable else {
            throw SensorError.sensorNotAvaliable
        }
        
        if self.motion.isDeviceMotionActive {
            print("Warning: Trying to start SensorManager that is already started")
            return
        }
        
        motion.startDeviceMotionUpdates(to: sensorOperation) { (data, error) in
            
            guard let data = data else {
                print("Missing sensor data on update \(#function)")
                if let error = error {
                    print(error)
                }
                return
            }
            
            self.sensorPublisher.send(MotionSensorData(data: data))
        }
    }
    
    public func stop() {
        self.motion.stopDeviceMotionUpdates()
    }
}

extension MotionSensorData {
    
    private static var gravity: Double { 9.81 }

    init(data: CMDeviceMotion) {
        let gravity = Self.gravity
        
        let timestampSensor = Int(data.timestamp * 1000)
        let timestampLocal = Int(Date().timeIntervalSince1970 * 1000)

        let accelerationData = [Float(data.userAcceleration.x * gravity),
                                Float(data.userAcceleration.y * gravity),
                                Float(data.userAcceleration.z * gravity)]

        let gravityData = [Float(data.gravity.x * -gravity),
                           Float(data.gravity.y * -gravity),
                           Float(data.gravity.z * -gravity)]

        let rotationData = [Float(data.attitude.quaternion.x),
                            Float(data.attitude.quaternion.y),
                            Float(data.attitude.quaternion.z),
                            Float(data.attitude.quaternion.w)]
        
        self.init(timestampSensor: timestampSensor,
                  timestampLocal: timestampLocal,
                  accelerationData: accelerationData,
                  gravityData: gravityData,
                  rotationData: rotationData)
    }
}
