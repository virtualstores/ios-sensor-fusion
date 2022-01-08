// FakeBackgroundAccessManager.swift
// VSSensorFusion

// Created by: CJ on 2022-01-08
// Copyright (c) 2022 Virtual Stores

#if os(iOS)
import Foundation
import Combine

public class FakeBackgroundAccessManager: IBackgroundAccessManager {
  public var isRunning = false

  public var isActive = false

  public var isLocationAccessEnabled = false

  public var backgroundAccessPublisher: CurrentValueSubject<Void, Error> = .init(())

  public init() {}

  public func requestLocationAccess() {
    // Do nothing
  }

  public func activate() {
    isActive = true
  }

  public func deactivate() {
    isActive = false
  }
}
#endif
