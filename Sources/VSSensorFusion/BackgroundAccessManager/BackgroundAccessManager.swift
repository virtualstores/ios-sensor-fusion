//
//  BackgroundAccessManager.swift
//  VSSensorFusion
//
//  Created by Karl Söderberg on 2021-12-10
// Copyright Virtual Stores - 2021
//

import Foundation
import CoreLocation
import UIKit

class BackgroundAccessManager: NSObject, IBackgroundAccessManager {
        
    public var isActive = true
    public var isRunning = false
    
    public var isLocationAccessEnabled: Bool {
        switch manager.authStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .denied, .notDetermined, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    private let manager = CLLocationManager()
    private let backgroundQueue = OperationQueue()
    
    public override init() {
        super.init()
        
        if #available(iOS 14.0, *) {
            manager.desiredAccuracy = kCLLocationAccuracyReduced
        }
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.distanceFilter = kCLDistanceFilterNone
        
        self.activate()
    }
    
    deinit {
        deactivate()
        print("BackgroundAccessManager Killed")
    }
    
    public func activate() {
        isActive = true
        manager.delegate = self
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: backgroundQueue, using: self.enteredBackground(_:))
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: backgroundQueue, using: self.enteredForeground(_:))
    }
    
    public func deactivate() {
        isActive = false
        NotificationCenter.default.removeObserver(self)
        stop()
        manager.delegate = nil
    }
    
    public func requestLocationAccess() {
        manager.requestAlwaysAuthorization()
    }
    
    private func start() {
        guard isLocationAccessEnabled else {
            print("WARN: App Doesnt have access to CoreLocation, please call requestLocationAccess() first")
            return
        }
        guard !isRunning else {
            print("WARN: LocationManager already running")
            return
        }
        
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                return
            }
            self.isRunning = true
            self.manager.startUpdatingLocation()
            self.manager.showsBackgroundLocationIndicator = true
        }
    }
    
    private func stop() {
        manager.stopUpdatingLocation()
        isRunning = false
        manager.showsBackgroundLocationIndicator = false
    }
    
    private func enteredBackground(_: Notification) {
        print("App entered background - BackgroundAccessManager started")
        start()
    }
    
    private func enteredForeground(_: Notification) {
        print("App entered foreground - BackgroundAccessManager paused")
        stop()
    }
}

// MARK: - CLLocationManagerDelegate
extension BackgroundAccessManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status -" , manager.authStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else {
            print("locationManager: did fail with unknown error", error)
            return
        }
        
        switch clError.code {
        case CLError.Code.denied:
            fallthrough
        default:
            print("locationManager: did fail with error", clError)
        }
        
        isRunning = false
    }
}
