//
//  RealmExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/4/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
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
    class func fetch<T: Object>(predicate: NSPredicate? = nil, realm: Realm? = nil) -> Observable<[T]> {
        guard let realm = realm ?? (try? Realm()) else { return Observable.error("Cannot initialize Realm") }
        return Observable.array(from: predicate != nil ? realm.objects(T.self).filter(predicate!) : realm.objects(T.self))
                .share(replay: 1)
    }
    
    /// fetch object by id
    class func get<T: Object>(with id: Int, realm: Realm? = nil) -> Observable<T> {
        guard let realm = realm ?? (try? Realm()) else { return Observable.error("Cannot initialize Realm") }
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

// MARK: - compiler-friendly fetches
extension Realm {
    
    /// fetch objects in a compiler-friendly way
    func fetch<T: Object>(type: T.Type, predicate: NSPredicate? = nil) -> Observable<[T]> {
        return T.fetch(predicate: predicate, realm: self)
    }
    
    /// fetch object by id in a compiler-friendly way
    func get<T: Object>(type: T.Type, with id: Int) -> Observable<T> {
        return T.get(with: id, realm: self)
    }
    
}

// MARK: - serialization
extension Object {
    
    /// converts to dictionary
    ///
    /// - Returns: dictionary
    func toDictionary() -> [AnyHashable: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var mutableDictionary = self.dictionaryWithValues(forKeys: properties)
        
        for prop in self.objectSchema.properties {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutableDictionary[prop.name] = nestedObject.toDictionary()
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [Any]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    if let object = nestedListObject._rlmArray[index] as? Object {
                        objects.append(object.toDictionary())
                    }
                }
                mutableDictionary[prop.name] = objects
            }
        }
        return mutableDictionary
    }
}
