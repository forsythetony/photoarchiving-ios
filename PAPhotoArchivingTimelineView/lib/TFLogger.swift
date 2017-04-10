//
//  TFLogger.swift
//  ImageCacheTest
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import CoreData

enum TFLogDomain : String {
    case General = "General"
    case Chromecast = "Chromecast"
    case ViewLayout = "View Layout"
    case Firebase =  "Firebase"
}

enum TFLogType : String {
    case Error = "Error"
    case Notification = "Notification"
    case Debugging = "Debugging"
    case Unknown = "Unknown"
}

class TFLogObject {
    var logType = TFLogType.Unknown
    var logDate = Date()
    var logDateString : String {
        get {
            return PADateManager.sharedInstance.getDateString(date: self.logDate, formatType: .FirebaseFull)
        }
    }
    
    var logMessage = ""
    var logPriority = 0
    var logCode = 0
    var uid : String = NSUUID().uuidString
    var logDomain = TFLogDomain.General
    
}
class TFLogger {
    
    static let sharedInstance = TFLogger()
    
    static let shouldLog = true
    static let useDelimiter = true
    static let delimiter = "--------------"
    
    
    init() {
        self.setupCoreData()
    }
    
    
    static func log( logString : String, arguments : String...) {
        
        if shouldLog {
            
            guard arguments.count > 0 else {
                print(logString)
                return
            }
            
            var newString = logString
            
            
            let argCount = arguments.count
            var counter = 0
            
            var currRange = newString.getNextRangeOccurrenceOfString(str: "%@")
            
            while( currRange != nil && counter < argCount) {
                
                
                let currArg = arguments[counter]
                
                newString = newString.replacingCharacters(in: currRange!, with: currArg)
                
                currRange = newString.getNextRangeOccurrenceOfString(str: "%@")
                
                counter += 1
            }
            
            if TFLogger.useDelimiter {
                print("\(newString)\n\(TFLogger.delimiter)")
                TFLogger.writeLogToFile(str: newString)
                
            } else {
                print("\(newString)\n")
            }
            
            
        }
    }
    
    static func log( str : String, err : Error) {
        
        TFLogger.log(logString: "%@\nError Description -> %@", arguments: str, err.localizedDescription)
    }
    
    
    
    
    
    
    
    //  MARK: Core Data
    
    
    
    var managedObjectContext : NSManagedObjectContext?
    private var isCoreDataSetup = false
    
    private func setupCoreData() {
        
        guard let modelURL = Bundle.main.url(forResource: "PAPhotoArchivingModel", withExtension: "momd") else {
            
            let errorMessage = "There was an error opening the model URL"
            fatalError(errorMessage)
            
        }
        
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            let errorMessage = "There was an error creating the managed object model"
            
            fatalError(errorMessage)
        }
        
        
         let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        DispatchQueue.main.async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            
            if let docURL = urls.last {
                
                let storeFileName = "PAPhotoArchivingModel.sqlite"
                
                let storeURL = docURL.appendingPathComponent(storeFileName)
                
                do {
                    try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "configName", at: storeURL, options: nil)
                    self.isCoreDataSetup = true
                } catch let err {
                    let errorMessage = "There was an error creating the persistent store...\(err.localizedDescription)"
                    
                    fatalError(errorMessage)
                }
            }
            else {
                let errorMessage = "There was no last document URL"
                fatalError(errorMessage)
            }
        }
        
        
        
    }
    
    
    func log( domain : TFLogDomain, logString : String, arguments : String...) {
        
        let logMessage = String.PAStringByReplacement(str: logString, arguments: arguments)
        
        let newLog = TFLogObject()
        
        
        newLog.logMessage = logMessage
        
    }
}

extension String {
    
    func getNextRangeOccurrenceOfString( str : String ) -> Range<String.Index>? {
        
        return self.range(of: str)
        
    }
    func getRangesOfOccurrencesOfString( str : String ) -> [Range<String.Index>] {
        
        var ranges = [Range<String.Index>]()
        
        var rangeStart : Index = self.index(self.endIndex, offsetBy: -1)
        let rangeEnd : Index = self.endIndex
        
        var substring = self
        
        while (true) {
            
            if rangeStart >= rangeEnd {
                break;
            }
            
            
            substring = substring.substring(to: rangeEnd)
            
            if let firstRange = substring.range(of: str) {
                
                rangeStart = firstRange.upperBound
                
                ranges.append(firstRange)
            }
            else {
                break;
            }
            
            
        }
        
        return ranges
    }
}

extension TFLogger {
    
    static func writeLogToFile( str : String ) {
        
        if let docs_dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            
            var file_name = "logger_file.txt"
            
            file_name = docs_dir.stringByAppendingPathComponent(path: file_name)
            
            print(file_name)
            
            if !FileManager.default.fileExists(atPath: file_name) {
                FileManager.default.createFile(atPath: file_name, contents: nil, attributes: nil)
            }
            
            var handle = FileHandle(forUpdatingAtPath: file_name)
            
            handle?.seekToEndOfFile() 
            
            if let str_data = str.data(using: .utf8) {
                handle?.write(str_data)
            }
            handle?.closeFile()
            
        }
        
    }
}
extension String {
    
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
    
    func getThumbnailFileName() -> String {
        
        var index = 0
        
        for i in self.characters {
            
            if i == "." {
                
                return self.insert(string: "_thumb", ind: index - 1)
            }
            
            index += 1
        }
        
        return ""
    }
    mutating func addBeginningSlash() {
        if !self.hasPrefix("/") {
            self.insert("/", at: self.startIndex)
        }
    }
    
    func stringByAppendingPathComponent( path : String ) -> String {
        let nsStr = self as NSString
        
        return nsStr.appendingPathComponent(path)
    }
    
}
