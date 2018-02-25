//
//  Tag.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Modified by TCCODER on 2/23/18.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * story tag
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
class Tag: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var value = ""
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
