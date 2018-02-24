//
//  Racetrack.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

/**
 * racetrack
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Racetrack: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var stateId = 0
    @objc dynamic var locality = ""
    @objc dynamic var street = ""
    @objc dynamic var locationLat = 0.0
    @objc dynamic var locationLng = 0.0
    
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
    /// ignored properties
    ///
    /// - Returns: ignored properties
    override static func ignoredProperties() -> [String] {
        return ["distance", "distanceText", "state", "pState"]
    }
    
    /// stored state
    private var pState: State?
    
}

// MARK: - ignored fields
extension Racetrack {
    
    /// distance text
    var distance: CLLocationDistance? {
        guard let currentLocation = LocationManager.shared.currentLocation else { return nil }
        let location = CLLocation(latitude: locationLat, longitude: locationLng)
        return location.distance(from: currentLocation)
    }
    
    /// distance text
    var distanceText: String {
        guard let distance = self.distance else { return "N/A miles".localized }
        
        return "\(distance.shortcut) miles"
    }
    
    /// state
    var state: State! {
        if pState == nil {
            pState = realm?.object(ofType: State.self, forPrimaryKey: stateId)
        }
        return pState
    }
    
}
