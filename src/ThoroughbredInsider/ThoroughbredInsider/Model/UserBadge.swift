//
//  UserBadge.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * User's badge
 *
 * - author: TCCODER
 * - version: 1.0
 */
class UserBadge: Object {

    /// fields
    @objc dynamic var userId = 0
    var badge: Badge!

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> UserBadge {
        let object = UserBadge()
        object.userId = json["userId"].intValue
        object.badge = Badge.fromJson(json["badge"])
        return object
    }
}
