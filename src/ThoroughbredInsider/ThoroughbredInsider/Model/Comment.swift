//
//  Comment.swift
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
 * Comment
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `fromJson` added
 * - fields changed to reflect API
 */
class Comment: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var chapterId = 0
    @objc dynamic var text = ""
    @objc dynamic var userId = 0

    var user: User!
    @objc dynamic var type = ""

    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Comment {
        let object = Comment()
        object.id = json["id"].intValue
        object.trackStoryId = json["trackStoryId"].intValue
        object.chapterId = json["chapterId"].intValue
        object.text = json["text"].stringValue
        object.userId = json["userId"].intValue

        object.user = User.fromJson(json["user"])
        object.type = json["type"].stringValue
        object.createdAt = DateFormatters.responseDate.date(from: json["createdAt"].stringValue) ?? Date()
        object.updatedAt = DateFormatters.responseDate.date(from: json["updatedAt"].stringValue) ?? Date()
        return object
    }

    /// Convert to parameters
    ///
    /// - Returns: the dictionary
    func toParameters() -> [String: Any] {
        let dic: [String: Any] = [
            "trackStoryId": trackStoryId,
            "chapterId": chapterId,
            "text": text,
            "type": type
        ]
        return dic
    }
}
