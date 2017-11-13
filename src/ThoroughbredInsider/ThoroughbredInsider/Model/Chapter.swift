//
//  Chapter.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//Copyright © 2017 Topcoder. All rights reserved.
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
    @objc dynamic var storyId = 0
    @objc dynamic var video = ""
    @objc dynamic var title = ""
    @objc dynamic var content = ""
    @objc dynamic var current = 0
    @objc dynamic var total = 0
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

}
