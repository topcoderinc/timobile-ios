//
//  Card.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/23/18.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * story reward card
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class Card: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var imageURL = ""
    @objc dynamic var name = ""
    @objc dynamic var descr = ""
    @objc dynamic var isEarned = false
    @objc dynamic var pts = 0
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
