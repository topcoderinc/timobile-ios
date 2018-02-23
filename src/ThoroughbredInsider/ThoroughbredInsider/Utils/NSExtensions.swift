//
//  NSExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Copyright © 2018  topcoder. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: - class name
extension NSObject {
 
    /// class name
    static var className: String {
        return String(describing: self)
    }
    
    /// class name
    var className: String {
        return String(describing: type(of: self))
    }
    
}

// MARK: - string extensions
extension String {
    
    /**
     Get string without spaces at the end and at the start.
     
     - returns: trimmed string
     */
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}

// MARK: - validation
extension String {
    
    /// email validation
    var isValidEmail: Bool {
        let pattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$"
        return range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
}


// MARK: - date extensions
extension Date {
    
    /**
     Check if current date is after the given date
     
     - parameter date: the date to check
     
     - returns: true - if current date is after
     */
    func isAfter(date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedDescending
    }
    
    /// get year
    var year: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return components.year!
    }
}

// MARK: - date formatting
extension Date {
    
    /// default date formatter
    static let DefaultFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        return df
    }()
    
    /// medium date formatter
    static let MediumFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        return df
    }()
    
    /// full date formatter
    static let FullFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    
    /// default formatted string
    var defaultFormat: String {
        return Date.DefaultFormatter.string(from: self)
    }
    
    /// medium formatted string
    var mediumFormat: String {
        return Date.MediumFormatter.string(from: self)
    }
    
    /// full formatted string
    var fullFormat: String {
        return Date.FullFormatter.string(from: self)
    }
    
}


// MARK: - json extensions
extension JSON {
    
    /// Get JSON from resource file
    ///
    /// - Parameter name: resource name
    /// - Returns: json
    static func resource(named name: String) -> JSON? {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: Data
        do {
            data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.dataReadingMapped)
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        // parse json
        return JSON(data: data)
    }
    
    /// same as .object but with all date strings converted to dates
    func objectWithConvertedDates(using formatter: DateFormatter = Date.DefaultFormatter) -> Any {
        if let dict = dictionary {
            return dict.mapValues { $0.lowercased().contains("date") ? formatter.date(from: $1.stringValue) as Any : $1.objectWithConvertedDates(using: formatter) }
        }
        else if let array = array {
            return array.map { $0.objectWithConvertedDates(using: formatter) }
        }
        return object
    }
    
    /// same as .object but with all 'description' replaced with descrName
    func objectWithDescriptionMapped(to descrName: String) -> Any {
        if let dict = dictionary {
            var resultDict = [String: JSON]()
            for (k, v) in dict {
                resultDict[k.lowercased() == "description" ? descrName : k] = v
            }
        }
        else if let array = array {
            return array.map { $0.objectWithDescriptionMapped(to: descrName) }
        }
        return object
    }
    
}


// MARK: - dictionary extension
extension Dictionary {
    
    /// Maps only the values of receiver and returns as a new dictionary
    func mapValues<T>(_ transform: (Key, Value)->T) -> Dictionary<Key,T> {
        var resultDict = [Key: T]()
        for (k, v) in self {
            resultDict[k] = transform(k, v)
        }
        return resultDict
    }
    
    
}

// MARK: - date extension
extension Date {
    
    /// Returns now many hours, minutes, etc. the date is from now.
    ///
    /// - Returns: string, e.g. "5h ago"
    func timeAgo() -> String {
        let timeInterval = Date().timeIntervalSince(self)
        
        let weeks = Int(floor(timeInterval / (7 * 3600 * 24)))
        let days = Int(floor(timeInterval / (3600 * 24)))
        let hours = Int(floor((timeInterval.truncatingRemainder(dividingBy: (3600 * 24))) / 3600))
        let minutes = Int(floor((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60))
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        if weeks > 0 { return "\(weeks)w ago" }
        if days > 0 { return  "\(days)d ago" }
        if hours > 0 { return "\(hours)h ago"}
        if minutes > 0 { return "\(minutes)m ago" }
        if seconds > 0 { return "\(seconds)s ago" }
        return "Now"
    }
    
}

// MARK: - dictionary extension
extension Dictionary where Value: Optionable {
    
    /// flattens dictionary values
    ///
    /// - Returns: flattened dictionary
    func flattenValues() -> [Key: Value.Wrapped] {
        var result = [Key: Value.Wrapped]()
        for (k, v) in self {
            if let v = v.value {
                result[k] = v
            }
        }
        return result
    }
    
}
