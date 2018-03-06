//
//  FileUtil.swift
//  ThoroughbredInsider
//
//  Created by TCCODER on 26/10/17.
//  Modified by TCCODER on 2/23/18.
//  Copyright © 2018  topcoder. All rights reserved.
//

import Foundation

/**
 * Utility for accessing local files (save/load)
 *
 * @author TCCODER
 * @version 1.0
 */
class FileUtil {

    // Subdirectory name for saved files
    static let CONTENT_DIR = "content"
    
    /**
     Saves content file with given id and data. Returns url to local file or nil if error occur

     - parameter fileName: the file name
     - parameter data:     the data

     - returns: the URL of the file
     */
    class func saveContentFile(_ fileName: String, data: Data) -> URL? {
        if saveDataToDocumentsDirectory(data, path: fileName, subdirectory: CONTENT_DIR) {
            return FileUtil.getLocalFileURL(fileName)
        }
        return nil
    }

    /**
     Remove given file

     - parameter fileName: the file name
     */
    class func removeFile(_ fileName: String) {
        let path = fileName
        let subdirectory = CONTENT_DIR

        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path+"/"

        // Subdirectory
        savePath += subdirectory
        savePath += "/"

        // Add requested save path
        savePath += path

        if FileManager.default.fileExists(atPath: savePath as String, isDirectory:nil) {

            // Remove file
            do {
                try FileManager.default.removeItem(atPath: savePath)
            } catch let error {
                print(error)
            }
        }
    }

    /**
     Saves data on the given path in subdirectory in Documents

     - parameter fileData:     the data
     - parameter path:         the main path
     - parameter subdirectory: the subdirectory name

     - returns: true - if successfully saved, false - else
     */
    class func saveDataToDocumentsDirectory(_ fileData: Data, path: String, subdirectory: String?) -> Bool {

        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path + "/"

        // Subdirectory
        if let dir = subdirectory {
            savePath += dir
            _ = self.createSubDirectory(savePath)
            savePath += "/"
        }

        // Add requested save path
        savePath += path

        // Save the file and see if it was successful
        let ok: Bool = FileManager.default.createFile(atPath: savePath, contents:fileData, attributes:nil)

        // Return status of file save
        return ok
    }

    /**
     Returns url to local file by fileNames

     - parameter fileName: the file name

     - returns: the URL
     */
    class func getLocalFileURL(_ fileName: String, subdirectory: String = CONTENT_DIR) -> URL {
        return URL(fileURLWithPath: "\(self.applicationDocumentsDirectory().path)/\(subdirectory)/\(fileName)")
    }

    /**
     Returns url to Documents directory of the current app

     - returns: the URL
     */
    class func applicationDocumentsDirectory() -> URL {
        return URL(string: applicationDocumentsDirectory()!)!
    }

    /**
     Returns url to Documents directory of the current app as a string

     - returns: the URL
     */
    class func applicationDocumentsDirectory() -> String? {
        let paths: [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                  FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths.first
    }

    /**
     Creates directory is not exists

     - parameter subdirectoryPath: the subdirectoty name

     - returns: true - if created successfully or exists, false - else
     */
    class func createSubDirectory(_ subdirectoryPath: String) -> Bool {
        var isDir: ObjCBool = false;
        let exists = FileManager.default.fileExists(atPath: subdirectoryPath as String, isDirectory:&isDir)
        if exists {
            // a file of the same name exists, we don't care about this so won't do anything
            if isDir.boolValue {
                // subdirectory already exists, don't create it again
                return true
            }
        }
        do {
            try FileManager.default.createDirectory(atPath: subdirectoryPath,
                                                    withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch {
            print("ERROR: \(error)")
        }
        return false
    }
}
