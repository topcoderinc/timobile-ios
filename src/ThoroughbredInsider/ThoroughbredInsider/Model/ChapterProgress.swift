//
//  ChapterProgress.swift
//  ThoroughbredInsider
//
//  Created by Nikita Rodin on 2/22/18.
//Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Chapter progress
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChapterProgress: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryUserProgressId = 0
    @objc dynamic var chapterId = 0
    @objc dynamic var wordsRead = 0
    @objc dynamic var completed = false
    
}
