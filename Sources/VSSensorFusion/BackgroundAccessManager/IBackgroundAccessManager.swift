//
//
//  IBackgroundAccessManager.swift
//  VSSensorFusion
//
//  Created by Karl Söderberg on 2021-12-10
//  Copyright Virtual Stores - 2021
//

import Foundation
import Combine
import CoreLocation

/// Manager for enabling running in the background.
/// Current implementation is BackgroundAccessManager class
public protocol IBackgroundAccessManager {
    /// Is true when LocationServices are actively tracking location
    var isRunning: Bool { get }
    
    /// Is true when the manager is actively keeping the background operations alive
    /// This does not mean that the LocationsServices are actively running since its only needed when the device is in background
    var isActive: Bool { get }
    
    /// Returns true if locations authorization is accepted. Will return false if "Not Determined"
    var isLocationAccessEnabled: Bool { get }
    
    /// Publishes the location updae error.
    var backgroundAccessPublisher: CurrentValueSubject<Void, Error> { get }

    /// Publishes the current heading from CLLocationManager
    var locationHeadingPublisher: CurrentValueSubject<CLHeading, Error> { get }

    /// Requests location access. This is needed before the manager can be active.
    func requestLocationAccess()
    
    /// Activates the listeners to check if device is going to background and triggers a LocationServices in order to be able to run in background.
    func activate()
    
    /// Deactivates the listener to check if device is going to background.
    /// Also stops all background LocationServices and stops running in the background.
    func deactivate()

    func vpsRunning(isRunning: Bool)
}
