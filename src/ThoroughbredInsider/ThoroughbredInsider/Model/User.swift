//
//  User.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import SwiftyJSON

/**
 * User model objects (represents profile data)
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - changes related to API integration
 */
class User: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var profilePhotoURL = ""
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var email = ""
    @objc dynamic var role = ""

    // the fields required for other not integrated screens
    @objc dynamic var reviews = 0
    @objc dynamic var badges = 0
    @objc dynamic var stories = 0
    @objc dynamic var cards = 0
    var tradingCards = List<Card>()
    var badgesList = List<Badge>()
    
    /// primary key
    override class func primaryKey() -> String? {
        return "id"
    }

    /// ignored properties
    ///
    /// - Returns: ignored properties
    override static func ignoredProperties() -> [String] {
        return ["avatar", "name"]
    }

    /// the full name
    var name: String {
        get {
            return (firstName + " " + lastName).trim()
        }
        set {
            var a = name.split(separator: " ")
            if a.count > 1 {
                firstName = String(a[0])
                lastName = a[1...a.count].joined(separator: " ")
            }
            else {
                firstName = name
                lastName = ""
            }
        }
    }

    /// Parse object from JSON
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> User {
        let object = User()
        object.id = json["id"].intValue
        object.profilePhotoURL = json["profilePhotoURL"].stringValue
        object.firstName = json["firstName"].stringValue
        object.lastName = json["lastName"].stringValue
        object.email = json["email"].stringValue
        object.role = json["role"].stringValue
        return object
    }

    /// Convert to parameters
    ///
    /// - Returns: the dictionary
    func toParameters() -> [String: Any] {
        var dic: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
            ]
        if !self.profilePhotoURL.isEmpty {
            dic["profilePhotoURL"] = self.profilePhotoURL
        }
        if id > 0 {
            dic["id"] = self.id
        }
        // `role` and `pointsAmount` are not needed
        return dic
    }
}

extension User {
    
    /// avatar image
    var avatar: UIImage? {
        get {
            return UIImage.init(contentsOfFile: profilePhotoURL)
        }
        set {
            if let image = newValue {
                self.profilePhotoURL = FileUtil.saveContentFile("user-\(id)", data: UIImagePNGRepresentation(image)!)?.lastPathComponent ?? ""
            }
        }
    }
    
}
