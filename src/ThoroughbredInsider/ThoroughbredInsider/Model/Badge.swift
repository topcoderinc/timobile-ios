//
//  Badge.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * Badge model object
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `fromJson` added
 * - fields changed to reflect API
 */
class Badge: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var isEarned = false
    @objc dynamic var name = ""
    @objc dynamic var desc = ""
    @objc dynamic var imageUrl = ""

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Badge {
        let object = Badge()
        object.id = json["id"].intValue
        object.trackStoryId = json["trackStoryId"].intValue
        object.name = json["name"].stringValue
        object.desc = json["description"].stringValue
        object.imageUrl = json["imageUrl"].stringValue
        return object
    }
    
}
