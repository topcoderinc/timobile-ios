//
//  Card.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * story reward card
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Card: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var image = ""
    @objc dynamic var name = ""
    @objc dynamic var content = ""
    @objc dynamic var isEarned = false
    @objc dynamic var pts = 0
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
