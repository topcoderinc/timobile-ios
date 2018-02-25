//
//  Comment.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 23/2/18.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Comment
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class Comment: Object {
    
    /// types
    enum CommentType: String {
        case story = "TrackStory"
        case chapter = "Chapter"
    }
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var chapterId = 0
    @objc dynamic var userId = 0
    @objc dynamic var text = ""
    @objc dynamic var type = ""
    @objc dynamic var image = ""
    @objc dynamic var user: User?
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
