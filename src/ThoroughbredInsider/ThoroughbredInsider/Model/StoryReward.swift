//
//  StoryReward.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/23/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * Story reward
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryReward: Object {

    /// fields
    var userBadge: UserBadge!
    var userCards = List<UserCard>()

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> StoryReward {
        let object = StoryReward()
        object.userBadge = UserBadge.fromJson(json["userBadge"])
        object.userCards.append(objectsIn: json["userCards"].arrayValue.map{UserCard.fromJson($0)})
        return object
    }
}
