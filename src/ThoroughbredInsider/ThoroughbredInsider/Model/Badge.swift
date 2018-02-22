//
//  Badge.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * bagde
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Badge: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var isEarned = false
    @objc dynamic var name = ""
    @objc dynamic var content = ""
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
