//
//  LocationManager.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * Location manager
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - changes required to obtain last known location and fix the case when user denies the services in "PreStory*" screen
 */
class LocationManager: NSObject, CLLocationManagerDelegate {

    /// shared instance
    static var shared = LocationManager()
    
    /// underlying manager
    private var locationManager: CLLocationManager?
    
    /// is already authorized
    var isAuthorized: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }

    /// flag: true - if user allowed location service, false - else
    var allowedByUser: Bool {
        get {
            return UserDefaults.locationServicesAllowed
        }
        set {
            UserDefaults.locationServicesAllowed = newValue
        }
    }
    
    /// are services enabled
    var locationServicesEnabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    /// the last known locations
    var locations: [CLLocation]?

    /// the callback used to update location
    var locationUpdated: (()->())?
    
    // MARK: - Public
    
    /// setup tracking with accuracy
    ///
    /// - Parameter accuracy: the accuracy
    func setupLocationServices(withDesiredAccuracy accuracy: CLLocationAccuracy = kCLLocationAccuracyThreeKilometers) {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = accuracy
        }
        if !isAuthorized && allowedByUser {
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
        self.locations = locations
        locationUpdated?()
    }
    
}
