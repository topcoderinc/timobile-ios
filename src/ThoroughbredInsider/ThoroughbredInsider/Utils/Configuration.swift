//
//  Configuration.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit

/**
 * A helper class to get the configuration data in the plist file.
 *
 * - author: TCCODER
 * - version: 1.1
 * 1.1:
 * - updates for integration
 */
final class Configuration: NSObject {
   
    // data
    var dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Configuration", ofType: "plist")!)
    
    // singleton
    static let sharedInstance = Configuration()
    
    // apiBaseUrl
    static var apiBaseUrl: String {
        return sharedInstance.dict!["apiBaseUrl"] as! String
    }
    
}
