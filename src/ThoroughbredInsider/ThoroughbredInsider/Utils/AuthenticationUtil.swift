//
//  AuthenticationUtil.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/21/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/// the constants used to store profile data
let kProfileImageUrl = "kProfileImageUrl"
let kAuthenticatedUserInfo = "kAuthenticatedUserInfo_v0.2"

/**
 * Utility for storing and getting current user profile data
 *
 * - author: TCCODER
 * - version: 1.0
 */
final class AuthenticationUtil {

    /// the user info
    var userInfo: UserInfo? {
        didSet {
            if let userInfo = userInfo {
                if rememberPassword { // persist only if need to save password
                    _ = userInfo.toJson().saveFile(kAuthenticatedUserInfo)
                }
            }
            else {
                FileUtil.removeFile(kAuthenticatedUserInfo)
            }
        }
    }

    /// flag for social login
    var isSocialLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isSocialLogin")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isSocialLogin")
            UserDefaults.standard.synchronize()
        }
    }

    /// flag: true - need to remember password, false - else
    var rememberPassword = false

    static let sharedInstance = AuthenticationUtil()

    // This prevents others from using the default '()' initializer for this class.
    private init() {
        if let json = JSON.contentOfFile(kAuthenticatedUserInfo) {
            self.userInfo = UserInfo.fromJson(json)
            rememberPassword = true
        }
    }

    /**
     Store userInfo

     - parameter userInfo: the data
     */
    func storeUserInfo(userInfo: UserInfo) {
        self.userInfo = userInfo
    }

    /**
     Check if user is already authenticated

     - returns: true - is user is authenticated, false - else
     */
    func isAuthenticated() -> Bool {
        return userInfo != nil && RESTApi.sharedInstance.hasAccessToken()
    }

    /**
     Clean up any stored user information
     */
    func cleanUp() {
        userInfo = nil
    }

    /**
     Get value by key

     - parameter key: the key

     - returns: the value
     */
    func getValueByKey(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }

    /**
     Save value to local preferences

     - parameter value: the value to save
     - parameter key:   the key
     */
    func saveValueForKey(_ value: String?, key: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey: key)
        defaults.synchronize()
    }

}

