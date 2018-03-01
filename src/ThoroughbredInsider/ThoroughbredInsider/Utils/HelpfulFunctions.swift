//
//  HelpfulFunctions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 2/21/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
 A set of helpful functions and extensions
 */

/**
 * Dictionary Extension
 * Some useful functions added to Dictionary class
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Dictionary {

    /// Create url string from Dictionary
    ///
    /// - Returns: the url string
    func toURLString() -> String {
        var urlString = ""

        // Iterate all key,value and form the url string
        for (key, value) in self {
            let value = (value as? String) ?? "\(value)"
            let keyEncoded = (key as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let valueEncoded = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            urlString += ((urlString == "") ? "" : "&") + keyEncoded + "=" + valueEncoded
        }
        return urlString
    }
}

/**
 * Helpful extension for arrays
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Array {

    /**
     Convert array to hash array

     - parameter transform: the transformation of an object to a key

     - returns: a hashmap
     */
    func hashmapWithKey<K>(_ transform: (Element) -> (K)) -> [K:Element] {
        var hashmap = [K:Element]()

        for item in self {
            let key = transform(item)
            hashmap[key] = item
        }
        return hashmap
    }
}

/**
 * Helpful extension for Int
 *
 * - author: TCCODER
 * - version: 1.0
 */
extension Int {

    /// Convert to string
    ///
    /// - Returns: string
    func toString() -> String {
        return "\(self)"
    }
}

/**
 * Date and time formatters
 *
 * - author: TCCODER
 * - version: 1.0
 */
struct DateFormatters {

    /// date formatter used to parse date from response
    static var responseDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        f.timeZone = TimeZone(abbreviation: "GMT")
        return f
    }()
}
