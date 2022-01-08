// IFakeSensorManager.swift
// VSSensorFusion

// Created by: CJ on 2022-01-08
// Copyright (c) 2022 Virtual Stores

import Foundation
import VSFoundation

public protocol IFakeSensorManager: ISensorManager {
  /// Sets the fake data that the sensor will output on start()
  func setFakeData(data: [MotionSensorData])
}
