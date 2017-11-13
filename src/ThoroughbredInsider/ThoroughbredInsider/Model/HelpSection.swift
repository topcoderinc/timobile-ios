//
//  HelpSection.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 11/2/17.
//  Copyright © 2017 Topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * Help section
 *
 * - author: TCCODER
 * - version: 1.0
 */
struct HelpSection {

    /// item type
    typealias Item = (title: String, text: String)
    
    /// fields
    let title: String
    let list: [Item]
    
    init(json: JSON) {
        title = json["title"].stringValue
        list = json["faq"].arrayValue.map { (title: $0["title"].stringValue, text: $0["text"].stringValue) }
    }
    
    /// load sections
    static var sections: [HelpSection] = {
        guard let json = JSON.resource(named: "faq") else { return [] }
        return json["items"].arrayValue.map { HelpSection(json: $0) }
    }()
    
}
