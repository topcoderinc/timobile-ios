//
//  State.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 10/31/17.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * state
 *
 * - author: TCCODER
 * - version: 1.0
 */
class State: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var value = ""
    @objc dynamic var name = ""
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }
    
    /// ignored properties
    ///
    /// - Returns: ignored properties
    override static func ignoredProperties() -> [String] {
        return ["shortcut"]
    }
}


// MARK: - ignored fields
extension State {
    
    /// shortcut name
    var shortcut: String { // ideally this should come from server
        return (value.count > 1 ? "\(value.first!)\(value.last!)" : value).uppercased()
    }
    
}
