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
import VSFoundation

public class BackgroundAccessManager: NSObject, IBackgroundAccessManager {
    public private(set) var isActive = true
    public private(set) var isRunning = false
    public private(set) var isVPSRunning = false
    
    public var backgroundAccessPublisher: CurrentValueSubject<Void, Error> = .init(())
    public static var locationPublisher: CurrentValueSubject<CLLocation?, Error> = .init(nil)
    public var locationHeadingPublisher: CurrentValueSubject<CLHeading?, Error> = .init(nil)
    public static var locationHeadingPublisher: CurrentValueSubject<CLHeading?, Error> = .init(nil)

    public var isLocationAccessEnabled: Bool {
        switch manager?.authStatus {
        case .authorizedAlways, .authorizedWhenInUse: return true
        case .denied, .notDetermined, .restricted, .none: return false
        @unknown default: return false
        }
    }

    private let tag = "BackgroundAccessManager"
    private var manager: CLLocationManager?

    public override init() {
        super.init()
        manager = CLLocationManager()

        if #available(iOS 14.0, *) {
            manager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation//kCLLocationAccuracyReduced
        }
        manager?.allowsBackgroundLocationUpdates = true
        manager?.pausesLocationUpdatesAutomatically = false
        manager?.distanceFilter = kCLDistanceFilterNone

        activate()
    }

    deinit {
      Logger(verbosity: .info).log(tag: tag, message: "deinit")
      dispose()
    }

    public func dispose() {
      Logger(verbosity: .info).log(tag: tag, message: "dispose")
      deactivate()
      manager?.stopUpdatingHeading()
      manager?.stopUpdatingLocation()
      manager = nil
    }

    public func activate() {
        isActive = true
        manager?.delegate = self
        requestLocationAccess()
        manager?.startUpdatingHeading()

        // TODO: Solve this
        addObservers() // Should not be added for for outdoors
    }

    var observersAdded = false
    func addObservers() {
      observersAdded = true
      NotificationCenter.default.addObserver(self, selector: #selector(enteredBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(enteredForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    public func deactivate() {
        isActive = false
        NotificationCenter.default.removeObserver(self)

        observersAdded = false
        stop()
        manager?.delegate = nil
    }

    public func vpsRunning(isRunning: Bool) {
        isVPSRunning = isRunning
        if !isRunning {
          stop()
        }
    }
    
    public func requestLocationAccess() {
        manager?.requestWhenInUseAuthorization()
    }
    
    public func start() {
        guard isLocationAccessEnabled, !isRunning, isVPSRunning else { return }
        #warning("WIP!")
        // TODO: Possible solution to combine Indoor and Outdoors Sensor fusion, remember to remove isVPSRunning above
        //if observersAdded, !isVPSRunning { return }

        let manager = manager
        DispatchQueue.global().async { [weak self] in
            guard CLLocationManager.locationServicesEnabled() else { return }
            self?.isRunning = true
            manager?.startUpdatingLocation()
            manager?.showsBackgroundLocationIndicator = true
        }
    }
    
    public func stop() {
        guard isRunning else { return }
        manager?.stopUpdatingLocation()
        isRunning = false
        manager?.showsBackgroundLocationIndicator = false
    }
    
    @objc private func enteredBackground(_: Notification) {
        start()
    }
    
  @objc private func enteredForeground(_: Notification) {
        stop()
    }
}


// MARK: - CLLocationManagerDelegate
extension BackgroundAccessManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Location authorization status -" , manager.authStatus)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    
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
