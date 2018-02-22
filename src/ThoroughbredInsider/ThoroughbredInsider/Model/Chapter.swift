//
//  Chapter.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * chapter
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Chapter: Object {

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
