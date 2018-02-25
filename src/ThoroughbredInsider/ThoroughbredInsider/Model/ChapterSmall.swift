//
//  ChapterSmall.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/25/18.
//Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Chapter content in story list
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChapterSmall: Object {

    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var video = ""
    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    @objc dynamic var content = ""
    @objc dynamic var number = 0
    @objc dynamic var wordsCount = 0
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
