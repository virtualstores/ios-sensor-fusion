//
//  BackgroundAccessManager.swift
//  VSSensorFusion
//
//  Created by Karl Söderberg on 2021-12-10
// Copyright Virtual Stores - 2021
//
#if os(iOS)
import Foundation
import Combine
import CoreLocation
import UIKit

public class BackgroundAccessManager: NSObject, IBackgroundAccessManager {
    public private(set) var isActive = true
    public private(set) var isRunning = false
    public private(set) var isVPSRunning = false
    
    public var backgroundAccessPublisher: CurrentValueSubject<Void, Error> = .init(())
    public static var locationPublisher: CurrentValueSubject<CLLocation?, Error> = .init(nil)
    public var locationHeadingPublisher: CurrentValueSubject<CLHeading?, Error> = .init(nil)
    public static var locationHeadingPublisher: CurrentValueSubject<CLHeading?, Error> = .init(nil)

    public var isLocationAccessEnabled: Bool {
        switch manager.authStatus {
        case .authorizedAlways, .authorizedWhenInUse: return true
        case .denied, .notDetermined, .restricted: return false
        @unknown default: return false
        }
    }
    
    private let manager = CLLocationManager()
    private let backgroundQueue = OperationQueue()
    
    public override init() {
        super.init()

        if #available(iOS 14.0, *) {
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation//kCLLocationAccuracyReduced
        }
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.distanceFilter = kCLDistanceFilterNone

        activate()
    }
    
    deinit {
        deactivate()
    }
    
    public func activate() {
        isActive = true
        manager.delegate = self
        requestLocationAccess()
        manager.startUpdatingHeading()

        addObservers() // Should not be added for for outdoors
    }

    var observersAdded = false
    func addObservers() {
      observersAdded = true
      NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: backgroundQueue, using: self.enteredBackground(_:))
      NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: backgroundQueue, using: self.enteredForeground(_:))
    }

    public func deactivate() {
        isActive = false
        NotificationCenter.default.removeObserver(self)
        observersAdded = false
        stop()
        manager.delegate = nil
    }

    public func vpsRunning(isRunning: Bool) {
        isVPSRunning = isRunning
    }
    
    public func requestLocationAccess() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func start() {
        guard isLocationAccessEnabled, !isRunning, isVPSRunning else { return }
        #warning("WIP!")
        // TODO: Possible solution to combine Indoor and Outdoors Sensor fusion, remember to remove isVPSRunning above
        //if observersAdded, !isVPSRunning { return }

        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else { return }
            self.isRunning = true
            self.manager.startUpdatingLocation()
            self.manager.showsBackgroundLocationIndicator = true
        }
    }
    
    public func stop() {
        guard isRunning else { return }
        manager.stopUpdatingLocation()
        isRunning = false
        manager.showsBackgroundLocationIndicator = false
    }
    
    private func enteredBackground(_: Notification) {
        start()
    }
    
    private func enteredForeground(_: Notification) {
        stop()
    }
}


// MARK: - CLLocationManagerDelegate
extension BackgroundAccessManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status -" , manager.authStatus)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { BackgroundAccessManager.locationPublisher.send($0) }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else {
            self.backgroundAccessPublisher.send(completion: .failure(error))
            return
        }
        
        switch clError.code {
        case CLError.Code.denied:
            fallthrough
        default:
            self.backgroundAccessPublisher.send(completion: .failure(clError))
        }

        isRunning = false
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.locationHeadingPublisher.send(newHeading)
        BackgroundAccessManager.locationHeadingPublisher.send(newHeading)
    }
}
#endif
