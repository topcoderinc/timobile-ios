//
//  StoryReward.swift
//  ThoroughbredInsider
//
//  Created by Nikita Rodin on 2/22/18.
//Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Story reward
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryReward: Object {

    /// fields
    @objc dynamic var userBadge: Badge?
    var userCards = List<Card>()

}
