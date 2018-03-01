//
//  Chapter.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * chapter
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `fromJson` added
 * - fields changed to reflect API
 */
class Chapter: Object {

    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var number = 0
    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    @objc dynamic var content = ""
    @objc dynamic var media = ""
    @objc dynamic var wordsCount = 0
    var progress: ChapterProgress?

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Chapter {
        let object = Chapter()
        object.id = json["id"].intValue
        object.trackStoryId = json["trackStoryId"].intValue
        object.number = json["number"].intValue
        object.title = json["title"].stringValue
        object.subtitle = json["subtitle"].stringValue
        object.content = json["content"].stringValue
        object.media = json["media"].stringValue
        object.wordsCount = json["wordsCount"].intValue
        return object
    }
}
