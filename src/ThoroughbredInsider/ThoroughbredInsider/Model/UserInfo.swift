//
//  UserInfo.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/21/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Class for storing user info (account data)
 *
 *  author: TCCODER
 *  version: 1.0
 */
public class UserInfo {

    /// the id
    var id = 0

    /// the email
    var email: String = ""

    /// the user's first name
    var firstName: String = ""

    /// the user's last name
    var lastName: String = ""

    /// the password
    var password: String = ""

    /// the profile photo URL
    var profilePhotoURL: String = ""

    /// the user's full name
    var fullName: String {
        return firstName + " " + lastName.trim()
    }

    /// Parse JSON into UserInfo
    ///
    /// - Parameter json: JSON object
    /// - Returns: UserInfo
    class func fromJson(_ json: JSON) -> UserInfo {
        let object = UserInfo()
        object.id = json["id"].intValue
        object.email = json["email"].stringValue
        object.password = json["password"].stringValue
        object.firstName = json["firstName"].stringValue
        object.lastName = json["lastName"].stringValue
        object.profilePhotoURL = json["profilePhotoURL"].stringValue
        return object
    }

    /// Convert UserInfo to JSON object
    ///
    /// - Returns: JSON object
    func toJson() -> JSON {
        var dic: [String: Any] = [
            "id": self.id,
            "email": self.email,
            "password": self.password,
            "firstName": self.firstName,
            "lastName": self.lastName
        ]
        if !self.profilePhotoURL.isEmpty {
            dic["profilePhotoURL"] = self.profilePhotoURL
        }
        return JSON(dic)
    }

    /// Convert to User
    ///
    /// - Returns: User
    func toUser() -> User {
        let object = User()
        object.id = id
        object.firstName = firstName
        object.lastName = lastName
        object.email = email
        object.profilePhotoURL = profilePhotoURL
        return object
    }
}

