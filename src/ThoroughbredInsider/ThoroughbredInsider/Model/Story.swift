//
//  Story.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/23/18.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Story
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class Story: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    @objc dynamic var largeImageURL = ""
    @objc dynamic var smallImageURL = ""
    @objc dynamic var bookmarked = false
    @objc dynamic var racetrack: Racetrack!
    @objc dynamic var badge: Badge?
    @objc dynamic var additionalTask: AdditionalTask?
    var cards = List<Card>()
    var chapters = List<ChapterSmall>()
    var tags = List<Tag>()    
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
    /// ignored properties
    ///
    /// - Returns: ignored properties
    override static func ignoredProperties() -> [String] {
        return ["summary"]
    }
    
}

// MARK: - ignored fields
extension Story {
    
    /// summary text
    var summary: String {
        return chapters.map { $0.content }.joined(separator: " ")
    }
    
}
