//
//  AdditionalTask.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

/**
 * Story additional task
 *
 * - author: TCCODER
 * - version: 1.0
 */
class AdditionalTask: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var trackStoryId = 0
    @objc dynamic var progressId = 0
    @objc dynamic var name = ""
    @objc dynamic var descr = ""
    @objc dynamic var points = 0

    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
    
}
