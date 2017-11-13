//
//  Comment.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Comment
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Comment: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var storyId = 0
    @objc dynamic var text = ""
    @objc dynamic var name = ""
    @objc dynamic var image = ""
    @objc dynamic var timestamp: TimeInterval = 0

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
