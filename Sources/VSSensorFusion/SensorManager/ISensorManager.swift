//
// ISensorManager
// VSSensorFusion
//
// Created by CJ on 2021-11-26
// Copyright Virtual Stores - 2021
//

import Foundation
import VSFoundation
import Combine

/// Manager for MotionSensor data. Will track device motions and publish them to sensorPublisher.
public protocol ISensorManager {
    
    /// Is SensorManager running or not. Determined by start()  and stop()
    var isRunning: Bool { get }
    
    /// Publishes the latest sensor data. Update interval is determined by implementing class
    var sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError> { get }
    
    /// Starts sensor managers sensor lokup. Will produce results to sensorPublisher.
    func start() throws
    
    /// Stops sensor managers sensor.
    func stop()
}

public enum SensorError: Error {
    case noData
    case sensorNotAvaliable
}
