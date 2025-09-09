// FakeBackgroundAccessManager.swift
// VSSensorFusion

// Created by: CJ on 2022-01-08
// Copyright (c) 2022 Virtual Stores

#if os(iOS)
import Foundation
import Combine
import CoreLocation

public class FakeBackgroundAccessManager: IBackgroundAccessManager {
  public var backgroundAccessPublisher: CurrentValueSubject<Void, any Error> = .init(())

  public var locationHeadingPublisher: CurrentValueSubject<CLHeading?, any Error> = .init(nil)
  
  public var isRunning = false

  public var isActive = false

  public var isLocationAccessEnabled = false

  public init() {}

  public func dispose() {}

  public func requestLocationAccess() {
    // Do nothing
  }

  public func activate() {
    isActive = true
  }

  public func deactivate() {
    isActive = false
  }

  public func vpsRunning(isRunning: Bool) {}

  public func start() {}

  public func stop() {}
}
#endif
