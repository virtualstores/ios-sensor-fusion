//
// SensorManager
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

public class SensorManager: ISensorManager {
    
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
            return
        }
        
        motion.startDeviceMotionUpdates(to: sensorOperation) { (data, error) in
            
            guard let data = data else {
                if let error = error {
                    throw SensorError.noData
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
