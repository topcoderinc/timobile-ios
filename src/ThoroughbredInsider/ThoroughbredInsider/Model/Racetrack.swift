//
//  Racetrack.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * racetrack
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `fromJson` added
 */
class Racetrack: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var code = ""
    @objc dynamic var name = ""
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Racetrack {
        let object = Racetrack()
        object.id = json["id"].intValue
        object.code = json["code"].stringValue
        object.name = json["name"].stringValue
        return object
    }
}
