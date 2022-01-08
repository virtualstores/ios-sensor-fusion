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

  private let sensorOperation = OperationQueue()
  private var fakeData: IndexingIterator<[MotionSensorData]>
  private var operationsCancellable: Cancellable?
  public var isRunning: Bool = false

  public init(data: [MotionSensorData]) {
    fakeData = data.makeIterator()
  }

  public func start() throws {
    if isRunning {
      return
    }

    fakeData.forEach { data in
      sensorOperation.schedule {
        self.sensorPublisher.send(data)
      }
    }
  }

  public func start(deviceMotionUpdateInterval: TimeInterval) throws {
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
