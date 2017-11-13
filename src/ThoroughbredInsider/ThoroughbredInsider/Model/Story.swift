//
//  Story.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//Copyright © 2017 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Story
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Story: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var code = ""
    @objc dynamic var name = ""
    @objc dynamic var image = ""
    @objc dynamic var race: Racetrack?
    @objc dynamic var content = ""
    @objc dynamic var chapters = 0
    @objc dynamic var cards = 0
    @objc dynamic var miles = 0
    @objc dynamic var lat: Double = 0
    @objc dynamic var long: Double = 0
    @objc dynamic var bookmarked = false
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
