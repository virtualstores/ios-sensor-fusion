//
//  CLLocationManager.swift
//  VSSensorFusion
//
//  Created by Felix Andersson on 2021-12-12.
//  Copyright Virtual Stores - 2021
//

import CoreLocation

extension CLLocationManager {
    var authStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return self.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
}
