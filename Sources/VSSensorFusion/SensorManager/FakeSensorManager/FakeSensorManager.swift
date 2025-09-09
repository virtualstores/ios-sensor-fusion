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

public class FakeSensorManager: IFakeSensorManager {
  public let sensorPublisher: CurrentValueSubject<MotionSensorData?, SensorError>  = .init(nil)
  public let altimeterPublisher: CurrentValueSubject<AltitudeSensorData?, SensorError> = .init(nil)

  private let sensorOperation = OperationQueue()
  private var fakeData: IndexingIterator<[MotionSensorData]>?
  private var operationsCancellable: Cancellable?
  public var isRunning = false

  public init() { }

  public func dispose() {
    
  }

  public func setFakeData(data: [MotionSensorData]) {
    fakeData = data.makeIterator()
  }
  public func start() throws {
    if isRunning {
      return
    }

    fakeData?.forEach { data in
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
      self.sensorPublisher.send(self.fakeData?.next())
    }
  }

  public func startMotion() throws {}

  public func startAltimeter() throws {}

  public func stop() {
    self.isRunning = false
    sensorOperation.cancelAllOperations()
    operationsCancellable?.cancel()
  }

  public func stopMotion() {}

  public func stopAltimeter() {}
}
