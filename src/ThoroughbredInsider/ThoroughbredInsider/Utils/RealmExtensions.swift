//
//  RealmExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/4/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import Realm
import RealmSwift
import RxCocoa
import RxSwift
import SwiftyJSON

// MARK: - object extensions
extension Object {
    
    /// creates a new object with auto id
    ///
    /// - Returns: object
    class func create(id: Int? = nil) -> Self {
        let object = self.init()
        object.setValue(id ?? object.incrementID, forKey: "id")
        return object
    }
    
    /// creates a new object with auto id
    ///
    /// - Returns: object
    class func create(json: JSON) -> Self {
        guard let realm = try? Realm() else { return self.init() }
        if let object = realm.object(ofType: self, forPrimaryKey: json[self.primaryKey()!].object) {
            let props = Set(RLMSchema.sharedSchema(for: self)?.properties.map { $0.name } ?? [])
            let primary = self.primaryKey()!
            try? object.realm?.write {
                for (k,v) in json.dictionaryValue {
                    guard k != primary else { continue }
                    if props.contains(k) {
                        object.setValue(v.object, forKey: k)
                    }
                }
            }
            return object
        }
        else {
            let object = self.init(value: json.object, schema: .partialPrivateShared())
            try? realm.write {
                realm.add(object)
            }
            return object
        }
    }
    
    /// auto incremented id
    var incrementID: Int {
        let realm = try! Realm()
        return (realm.objects(type(of: self)).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    /// auto incremented id
    class var incrementID: Int {
        let realm = try! Realm()
        return (realm.objects(self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    /// fetch objects
    class func fetch<T: Object>(predicate: NSPredicate? = nil) -> Observable<[T]> {
        guard let realm = try? Realm() else { return Observable.error("Cannot initialize Realm") }
        return Observable.array(from: predicate != nil ? realm.objects(T.self).filter(predicate!) : realm.objects(T.self))
                .share(replay: 1)
    }
    
    /// fetch objects
    class func get<T: Object>(with id: Int) -> Observable<T> {
        guard let realm = try? Realm() else { return Observable.error("Cannot initialize Realm") }
        var object = realm.object(ofType: T.self, forPrimaryKey: id)
        if object == nil {
            object = T.create(id: id)
            try? realm.write {
                realm.add(object!)
            }
        }
        return Observable.from(object: object!)
            .share(replay: 1)
    }
}
