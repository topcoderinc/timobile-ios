//
//  TokenUtil.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/22/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import KeychainAccess

/**
 * Token utility
 *
 * - author: TCCODER
 * - version: 1.0
 */
class TokenUtil {

    /// reference to Keychain
    private static let keychain = Keychain(service: "Thoroughbred-Insider")
 
    /// key for storing access token
    private static let kAccessToken = "kAccessToken"
    /// key for storing access token expiration date
    private static let kAccessTokenExpiration = "kAccessTokenExpiration"
    
    /// stored access token, initialized with still valid token if available
    static var accessToken: String? = {
        guard let token = keychain[kAccessToken],
            let dateStr = keychain[kAccessTokenExpiration],
            let date = Date.FullFormatter.date(from: dateStr),
            date.timeIntervalSinceNow > 0 else { return nil }
        return token
    }()
    
    
    /// stores token
    ///
    /// - Parameters:
    ///   - accessToken: token
    ///   - date: expiration date
    static func store(accessToken: String, until date: String) {
        self.accessToken = accessToken
        keychain[kAccessToken] = accessToken
        keychain[kAccessTokenExpiration] = date
    }
    
    /// cleanup credentials
    static func cleanup() {
        accessToken = nil
        keychain[kAccessToken] = nil
        keychain[kAccessTokenExpiration] = nil
    }
    
}
