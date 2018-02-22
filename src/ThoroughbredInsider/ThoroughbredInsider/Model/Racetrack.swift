//
//  Racetrack.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * racetrack
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Racetrack: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var value = ""
    @objc dynamic var name = ""
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
}
