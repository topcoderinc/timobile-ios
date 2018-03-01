//
//  StoryProgress.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * Story progress
 *
 * - author: TCCODER
 * - version: 1.0
 */
class StoryProgress: Object {

    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var userId = 0
    var chaptersUserProgress = List<ChapterProgress>()
    @objc dynamic var completed = false
    @objc dynamic var cardsAndRewardsReceived = false
    @objc dynamic var additionalTaskCompleted = false

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameters:
    ///   - json: JSON
    ///   - chapters: the map of chapters
    /// - Returns: the object
    class func fromJson(_ json: JSON, chapters: [Int:Chapter]) -> StoryProgress {
        let object = StoryProgress()
        object.id = json["id"].intValue
        object.trackStoryId = json["trackStoryId"].intValue
        object.userId = json["userId"].intValue
        object.chaptersUserProgress.append(objectsIn: json["chaptersUserProgress"].arrayValue.map({ChapterProgress.fromJson($0, chapters: chapters)}))
        object.completed = json["completed"].boolValue
        object.cardsAndRewardsReceived = json["cardsAndRewardsReceived"].boolValue
        object.additionalTaskCompleted = json["additionalTaskCompleted"].boolValue
        return object
    }

    /// Convert to parameters
    ///
    /// - Returns: the dictionary
    func toParameters() -> [String: Any] {
        let dic: [String: Any] = [
            "trackStoryId": trackStoryId,
            "userId": userId,
            "chaptersUserProgress": chaptersUserProgress.toArray().map{$0.toParameters(trackStoryUserProgressId: self.id)}
        ]
        return dic
    }
}
