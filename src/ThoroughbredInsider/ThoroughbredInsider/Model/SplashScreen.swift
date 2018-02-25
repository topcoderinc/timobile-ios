//
//  SplashScreen.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 9/1/17.
//  Modified by TCCODER on 23/2/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * Splash screen data
 *
 * - author: TCCODER
 * - version: 1.0
 */
struct SplashScreen {
    
    // data
    let title: String
    let contentText: String
    let imageName: String
    
    /// constructor from json
    ///
    /// - Parameter data: json data
    init(data: JSON) {
        title = data["title"].stringValue
        contentText = data["contentText"].stringValue
        imageName = data["imageName"].stringValue
    }
    
    
    /// loads predefined splash pages
    ///
    /// - Returns: splash screen data
    static func getPredefinedData() -> [SplashScreen] {
        var predefinedData = [SplashScreen]()
        
        guard let json = JSON.resource(named: "SplashScreenData") else { return [] }
        
        for screenJSON in json.arrayValue {
            predefinedData.append(SplashScreen(data: screenJSON))
        }
        
        return predefinedData
    }
    
}
