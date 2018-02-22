//
//  RecentSearch.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/1/17.
//Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * recent search
 *
 * - author: TCCODER
 * - version: 1.0
 */
class RecentSearch: Object {

    /// fields
    @objc dynamic var query = ""
    @objc dynamic var date = Date()

    /// primary key
    override class func primaryKey() -> String? {
        return "query"
    }
    
    /// upserts a new search
    ///
    /// - Parameter query: search query
    class func upsert(query: String) {
        guard !query.trim().isEmpty else { return }
        guard let realm = try? Realm() else { return }
        let recent = realm.object(ofType: self, forPrimaryKey: query) ?? self.init()
        try? realm.write {
            if recent.query.isEmpty {
                recent.query = query
            }
            recent.date = Date()
            realm.add(recent)
        }        
    }
    
}
