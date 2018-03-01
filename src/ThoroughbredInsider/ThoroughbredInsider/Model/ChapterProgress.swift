//
//  ChapterProgress.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * Chapter progress
 *
 * - author: TCCODER
 * - version: 1.0
 */
class ChapterProgress: Object {

    /// fields
    @objc dynamic var id = 0
    @objc dynamic var chapter: Chapter?
    @objc dynamic var wordsRead = 0
    @objc dynamic var completed = false

    /// Parse object from JSON
    ///
    /// - Parameters:
    ///   - json: JSON
    ///   - chapters: the map of chapters
    /// - Returns: the object
    class func fromJson(_ json: JSON, chapters: [Int:Chapter]) -> ChapterProgress {
        let object = ChapterProgress()
        object.id = json["id"].intValue
        object.chapter = chapters[json["chapterId"].intValue]
        object.wordsRead = json["wordsRead"].intValue
        object.completed = json["completed"].boolValue
        return object
    }

    /// Convert to parameters
    ///
    /// - Parameter trackStoryUserProgressId: the ID of the story progress
    /// - Returns: the dictionary
    func toParameters(trackStoryUserProgressId: Int) -> [String: Any] {
        let dic: [String: Any] = [
            "chapterId": chapter?.id ?? 0,
            "trackStoryUserProgressId": trackStoryUserProgressId,
            "wordsRead": wordsRead,
            "completed": completed
        ]
        return dic
    }
}
