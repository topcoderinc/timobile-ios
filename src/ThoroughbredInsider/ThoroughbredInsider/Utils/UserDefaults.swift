//
//  UserDefaults.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * User defaults wrapper
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension UserDefaults {

    /// first launch flag
    static var firstLaunch: Bool {
        get {
            return standard.bool(forKey: "firstLaunch")
        }
        set {
            standard.set(newValue, forKey: "firstLaunch")
            standard.synchronize()
        }
    }
    
    /// first story launch flag
    static var firstStoryLaunch: Bool {
        get {
        return standard.bool(forKey: "firstStoryLaunch")
        }
        set {
            standard.set(newValue, forKey: "firstStoryLaunch")
            standard.synchronize()
        }
    }
    
    /// logged in user
    static var loggedUserId: Int {
        get {
            return standard.integer(forKey: "loggedUserId")
        }
        set {
            standard.set(newValue, forKey: "loggedUserId")
            standard.synchronize()
        }
    }
    
    /// profile setting
    static var switchEmails: Bool {
        get {
            return standard.bool(forKey: "switchEmails")
        }
        set {
            standard.set(newValue, forKey: "switchEmails")
            standard.synchronize()
        }
    }
    
    /// profile setting
    static var switchAdmission: Bool {
        get {
            return standard.bool(forKey: "switchAdmission")
        }
        set {
            standard.set(newValue, forKey: "switchAdmission")
            standard.synchronize()
        }
    }
    
}
