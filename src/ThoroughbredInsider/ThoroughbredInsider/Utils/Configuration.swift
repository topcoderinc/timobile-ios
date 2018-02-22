//
//  Configuration.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2017 topcoder. All rights reserved.
//

import UIKit

/**
 * A helper class to get the configuration data in the plist file.
 *
 * - author: TCCODER
 * - version: 1.0
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
