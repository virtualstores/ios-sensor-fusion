// ISensorManager
// VSSensorFusion
//
// Created by CJ on 2021-11-26
// Copyright Virtual Stores - 2021
//

import Foundation
import VSFoundation
import Combine

public protocol ISensorManager {
    func start()
    func stop()
    func add(delegate: ISensorManagerDelegate)
    func remove(delegate: ISensorManagerDelegate)
}

public protocol ISensorManagerDelegate {
    var id: String { get }
    func onNewMotionSensorData(data: MotionSensorData)
}

public protocol ISensorManagerModern {
    var isRunning: Bool { get }
    var sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError> { get }
    
    func start() throws
    func stop()
}

public enum SensorError: Error {
    case noData
    case sensorNotAvaliable
}
