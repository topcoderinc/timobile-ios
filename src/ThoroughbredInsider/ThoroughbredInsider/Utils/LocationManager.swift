//
//  LocationManager.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * Location manager
 *
 * - author: TCCODER
 * - version: 1.0
 */
class LocationManager: NSObject, CLLocationManagerDelegate {

    /// shared instance
    static var shared = LocationManager()
    
    /// underlying manager
    private var locationManager: CLLocationManager?
    
    /// is already authorized
    var isAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    /// are services enabled
    var locationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    // MARK: - Public
    
    /// setup tracking with accuracy
    ///
    /// - Parameter accuracy: the accuracy
    func setupLocationServices(withDesiredAccuracy accuracy: CLLocationAccuracy = kCLLocationAccuracyThreeKilometers) {
        guard locationManager == nil else { return }
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = accuracy
        if !isAuthorized {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    /// starts updating location
    func startUpdatingLocation() {
        if locationServicesEnabled {
            setupLocationServices()
        }
        locationManager?.startUpdatingLocation()
    }
    
    /// stops updating location
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManager delegate
    
    /// location update
    ///
    /// - Parameters:
    ///   - manager: the manager
    ///   - locations: updated locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        stopUpdatingLocation()
    }
    
}
