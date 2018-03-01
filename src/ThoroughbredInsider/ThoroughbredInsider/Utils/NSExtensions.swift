//
//  NSExtensions.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 30/10/17.
//  Modified by TCCODER on 2/24/18.
//  Copyright © 2017-2018 Topcoder. All rights reserved.
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
/**
 * Extension adds methods String
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new methods
 */
extension String {

    /// the length of the string
    var length: Int {
        return self.count
    }

    /// Shortcut method for replacingOccurrences
    ///
    /// - Parameters:
    ///   - target: the string to replace
    ///   - withString: the string to add instead of target
    /// - Returns: a result of the replacement
    public func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString,
                                         options: NSString.CompareOptions.literal, range: nil)
    }

    /**
     Get string without spaces at the end and at the start.
     
     - returns: trimmed string
     */
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /**
     Checks if string contains given substring

     - parameter substring:     the search string
     - parameter caseSensitive: flag: true - search is case sensitive, false - else

     - returns: true - if the string contains given substring, false - else
     */
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if let _ = self.range(of: substring,
                              options: caseSensitive ? NSString.CompareOptions(rawValue: 0) : .caseInsensitive) {
            return true
        }
        return false
    }

    /// localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Checks if the string is number
    ///
    /// - Returns: true if the string presents number
    func isNumber() -> Bool {
        let formatter = NumberFormatter()
        if let _ = formatter.number(from: self) {
            return true
        }
        return false
    }

    /// Checks if the string is positive number
    ///
    /// - Returns: true if the string presents positive number
    func isPositiveNumber() -> Bool {
        let formatter = NumberFormatter()
        if let number = formatter.number(from: self) {
            if number.doubleValue > 0 {
                return true
            }
        }
        return false
    }

    /// Get substring, e.g. "ABCDE".substring(index: 2, length: 3) -> "CDE"
    ///
    /// - parameter index:  the start index
    /// - parameter length: the length of the substring
    ///
    /// - returns: the substring
    public func substring(index: Int, length: Int) -> String {
        if self.length <= index {
            return ""
        }
        let leftIndex = self.index(self.startIndex, offsetBy: index)
        if self.length <= index + length {
            return String(self[leftIndex...])
        }
        let rightIndex = self.index(self.endIndex, offsetBy: -(self.length - index - length))
        return String(self[leftIndex..<rightIndex])
    }

    /// Capitalize first word
    ///
    /// - Returns: the result
    func capitalizeFirstWord() -> String {
        var a = self.split(separator: " ").map{String($0)}
        if a.count > 1 { a[0] = a[0].capitalized }
        return a.joined(separator: " ")
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
    
    /// default formatted string
    var defaultFormat: String {
        return Date.DefaultFormatter.string(from: self)
    }
    
    /// medium formatted string
    var mediumFormat: String {
        return Date.MediumFormatter.string(from: self)
    }
    
}


// MARK: - json extensions

/**
 * Extension adds methods for reading and writing JSON objects
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - new methods
 */
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

    /**
     Save JSON object into given file

     - parameter fileName: the file name

     - returns: the URL of the saved file
     */
    func saveFile(_ fileName: String) -> Foundation.URL? {
        do {
            let data = try self.rawData()
            return FileUtil.saveContentFile(fileName, data: data)
        } catch {
            return nil
        }
    }

    /**
     Get JSON object from given file

     - parameter fileName: the file name

     - returns: JSONObject
     */
    static func contentOfFile(_ fileName: String) -> JSON? {
        let url = FileUtil.getLocalFileURL(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            if let data = try? Data(contentsOf: Foundation.URL(fileURLWithPath: url.path)) {
                let json = JSON(data: data)
                return json
            }
        }
        return nil
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
        return "Just now"
    }
    
}

/**
 *  Helper class for regular expressions
 *
 * - author: TCCODER
 * - version: 1.0
 */
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String

    init(_ pattern: String) {
        self.pattern = pattern
        self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }

    func test(_ input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: [],
                                                      range:NSMakeRange(0, input.count))
        return matches.count > 0
    }
}
precedencegroup RegexPrecedence {
    lowerThan: AdditionPrecedence
}

// Define operator for simplisity of Regex class
infix operator ≈: RegexPrecedence
public func ≈(input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}
