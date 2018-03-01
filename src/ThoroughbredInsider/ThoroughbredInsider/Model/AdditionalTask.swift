//
//  AdditionalTask.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/**
 * Additional task
 *
 * - author: TCCODER
 * - version: 1.0
 */
class AdditionalTask: Object {

    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var name = ""
    @objc dynamic var desc = ""
    @objc dynamic var points = 0
    @objc dynamic var progressId = 0

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> AdditionalTask {
        let object = AdditionalTask()
        object.id = json["id"].intValue
        object.trackStoryId = json["trackStoryId"].intValue
        object.name = json["name"].stringValue
        object.desc = json["description"].stringValue
        object.points = json["points"].intValue
        return object
    }

}
