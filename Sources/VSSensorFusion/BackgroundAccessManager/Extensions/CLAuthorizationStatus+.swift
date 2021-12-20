//
//  CLAuthorizationStatus+.swift
//  VSSensorFusion
//
//  Created by Karl Söderberg on 2021-12-10
// Copyright Virtual Stores - 2021
//

import CoreLocation

extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        get {
            switch self {
                case .notDetermined: return "NotDetermined"
                case .denied: return "Denied"
                case .restricted: return "Restricted"
                case .authorizedAlways: return "AuthorizedAlways"
                case .authorizedWhenInUse: return "AuthorizedWhenInUse"
                default: return "CLAuthorizationStatus"
            }
        }
    }
}
