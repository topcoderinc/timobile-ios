//
//  UserCard.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * User's card
 *
 * - author: TCCODER
 * - version: 1.0
 */
class UserCard: Object {

    /// fields
    @objc dynamic var userId = 0
    var card: Card!

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> UserCard {
        let object = UserCard()
        object.userId = json["userId"].intValue
        object.card = Card.fromJson(json["card"])
        return object
    }
}

