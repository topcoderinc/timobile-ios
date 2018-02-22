//
//  StoryProgress.swift
//  ThoroughbredInsider
//
//  Created by Nikita Rodin on 2/22/18.
//Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Story progress
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryProgress: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var userId = 0
    @objc dynamic var completed = false
    @objc dynamic var cardsAndRewardsReceived = false
    @objc dynamic var additionalTaskCompleted = false
    var chaptersUserProgress = List<ChapterProgress>()
}

