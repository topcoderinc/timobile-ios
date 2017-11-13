//
//  StoryDetails.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Story
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryDetails: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var code = ""
    @objc dynamic var name = ""
    @objc dynamic var image = ""
    @objc dynamic var summary = ""
    @objc dynamic var chapters = 0
    @objc dynamic var cards = 0
    @objc dynamic var bookmarked = false
    @objc dynamic var rewardsReceived = false
    @objc dynamic var completed = false
    @objc dynamic var additionalRewards = 0
    var rewards = List<Card>()
    var tags = List<Tag>()    
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}

