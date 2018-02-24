//
//  User.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

/**
 * data model
 *
 * - author: TCCODER
 * - version: 1.0
 */
class User: Object {
    
    /// fields
    @objc dynamic var id = 0
    @objc dynamic var profilePhotoURL: String?
    @objc dynamic var name = ""
    @objc dynamic var email = ""
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
        return ["avatar"]
    }
    
}

extension User {
    
    /// avatar image
    var avatar: UIImage? {
        get {
            return UIImage.init(contentsOfFile: profilePhotoURL ?? "")
        }
        set {
            if let image = newValue {
                self.profilePhotoURL = FileUtil.saveContentFile("user-\(id)", data: UIImagePNGRepresentation(image)!)?.lastPathComponent ?? ""
            }
        }
    }
    
}
