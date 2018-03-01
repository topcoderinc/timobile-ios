//
//  Card.swift
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
 * story reward card
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `fromJson` added
 * - fields changed to reflect API
 */
class Card: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var imageURL = ""
    @objc dynamic var name = ""
    @objc dynamic var content = ""
    @objc dynamic var type = ""
    @objc dynamic var pricePoints = 0

    @objc dynamic var isEarned = false

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Card {
        let object = Card()
        object.id = json["id"].intValue
        object.trackStoryId = json["trackStoryId"].intValue
        object.imageURL = json["imageURL"].stringValue
        object.name = json["name"].stringValue
        object.content = json["description"].stringValue
        object.type = json["type"].stringValue
        object.pricePoints = json["pricePoints"].intValue
        object.isEarned = true
        return object
    }
}
