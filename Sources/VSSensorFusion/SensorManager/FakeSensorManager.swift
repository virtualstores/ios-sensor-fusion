//
// FakeSensorManager
// VSSensorFusion
//
// Created by Karl Söderberg on 2021-12-05
// Copyright Virtual Stores - 2021
//

import Foundation
import VSFoundation
import Combine

public class FakeSensorManager: ISensorManager {
    
    public var sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)

    private let deviceMotionUpdateInterval: TimeInterval
    private let sensorOperation = OperationQueue()
    private var fakeData: IndexingIterator<[MotionSensorData]>
    private var operationsCancellable: Cancellable?
    public var isRunning: Bool = false
    
    public init(updateInterval: TimeInterval, data: [MotionSensorData]) {
        deviceMotionUpdateInterval = updateInterval
        fakeData = data.makeIterator()
    }

    public func start() throws {
        if isRunning {
            print("Warning: Trying to start SensorManager that is already started")
            return
        }
        
        operationsCancellable = sensorOperation.schedule(after: .init(Date()),
                                                         interval: .seconds(deviceMotionUpdateInterval),
                                                         tolerance: .zero,
                                                         options: nil) {
            self.sensorPublisher.send(self.fakeData.next())
        }
    }
    
    public func stop() {
        self.isRunning = false
        sensorOperation.cancelAllOperations()
        operationsCancellable?.cancel()
    }
}
