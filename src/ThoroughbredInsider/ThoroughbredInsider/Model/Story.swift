//
//  Story.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// option: true - crop the summary in Story List and Details page (as in Android), false - else.
/// Actually, without the same "Read More" behavior (UI issue maybe) it has not effect, but may help in future.
let OPTION_CROP_SUMMARY = true

/**
 * Story
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - `fromJson` added
 * - fields changed to reflect API
 */
class Story: Object {

    /// the maximum length of the story short description
    static let MAX_STORY_DESCRIPTION_LEN = 200

    /// fields
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    var tags = List<Tag>()
    var chapters = List<Chapter>()
    var cards = List<Card>()
    @objc dynamic var race: Racetrack?
    @objc dynamic var smallImageURL = ""
    @objc dynamic var largeImageURL = ""
    var badge: Badge?
    @objc dynamic var additionalTask: AdditionalTask?

    @objc dynamic var chapterContents = ""
    @objc dynamic var lat: Double = 0
    @objc dynamic var long: Double = 0
    @objc dynamic var bookmarked = false
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Get short description of the story
    ///
    /// - Returns: the description
    func getDescription() -> String {
        if OPTION_CROP_SUMMARY && self.chapterContents.length > Story.MAX_STORY_DESCRIPTION_LEN {
            return self.chapterContents.substring(index: 0, length: Story.MAX_STORY_DESCRIPTION_LEN) + "..."
        }
        return self.chapterContents
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> Story {
        let object = Story()
        object.id = json["id"].intValue
        object.title = json["title"].stringValue
        object.subtitle = json["subtitle"].stringValue
        object.tags.append(objectsIn: json["tags"].arrayValue.map{Tag.fromJson($0)})
        object.chapters.append(objectsIn: json["chapters"].arrayValue.map{Chapter.fromJson($0)})
        object.cards.append(objectsIn: json["cards"].arrayValue.map{Card.fromJson($0)})
        object.race = Racetrack.fromJson(json["racetrack"])
        object.smallImageURL = json["smallImageURL"].stringValue
        object.largeImageURL = json["largeImageURL"].stringValue
        if json["badge"]["id"].int != nil {
            object.badge = Badge.fromJson(json["badge"])
        }
        if json["additionalTask"]["id"].int != nil {
            object.additionalTask = AdditionalTask.fromJson(json["additionalTask"])
        }

        object.chapterContents = object.chapters.toArray().map{$0.content}.joined(separator: " ").trim()

        object.lat = json["racetrack"]["locationLat"].doubleValue
        object.long = json["racetrack"]["locationLng"].doubleValue
        object.bookmarked = json["bookmarked"].boolValue
        return object
    }
}
