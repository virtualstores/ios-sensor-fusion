// FakeSensorManager
// VSSensorFusion
//
// Created by Karl Söderberg on 2021-12-05
// Copyright Virtual Stores - 2021
//

import Foundation
import VSFoundation
import Combine

public class FakeSensorManager: ISensorManagerModern {
    
    public var sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)

    private let deviceMotionUpdateInterval: TimeInterval
    private let sensorOperation = OperationQueue()
    private var fakeData: IndexingIterator<[MotionSensorData]>
    private let isRepeating: Bool
    private var operationsCancellable: Cancellable?
    public var isRunning: Bool = false
    

    public init(updateInterval: TimeInterval, data: [MotionSensorData], repeats: Bool) {
        deviceMotionUpdateInterval = updateInterval
        fakeData = data.makeIterator()
        isRepeating = repeats
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

//extension MotionSensorData {
//    
//    private static var gravity: Double { 9.81 }
//
//    init() {
//        let gravity = Self.gravity
//        
//        let timestampSensor = Int(data.timestamp * 1000)
//        let timestampLocal = Int(Date().timeIntervalSince1970 * 1000)
//
//        let accelerationData = [Float(data.userAcceleration.x * gravity),
//                                Float(data.userAcceleration.y * gravity),
//                                Float(data.userAcceleration.z * gravity)]
//
//        let gravityData = [Float(data.gravity.x * -gravity),
//                           Float(data.gravity.y * -gravity),
//                           Float(data.gravity.z * -gravity)]
//
//        let rotationData = [Float(data.attitude.quaternion.x),
//                            Float(data.attitude.quaternion.y),
//                            Float(data.attitude.quaternion.z),
//                            Float(data.attitude.quaternion.w)]
//        
//        self.init(timestampSensor: timestampSensor,
//                  timestampLocal: timestampLocal,
//                  accelerationData: accelerationData,
//                  gravityData: gravityData,
//                  rotationData: rotationData)
//    }
//}
