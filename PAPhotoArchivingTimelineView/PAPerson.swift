//
//  PAPerson.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PAPerson {
    
    var uid         = ""
    var firstName   = ""
    var lastName    = ""
    
    var birthDate       : Date?
    var birthDateConf   : Float = 0.0
    var deathDate       : Date?
    var deathDateConf   : Float = 0.0
    
    var profileImageURL = ""
    var profileThumbImageURL = ""
    
    var birthPlace      : PALocation?
    var birthPaceConf   : Float = 0.0
}

class PAUser : PAPerson {
    
    var dateLastLoggedIn : Date?
    var photosContributed : [PAPhotograph]?
    var mostActiveRepository : PARepository?
    var repositoriesJoined : [PARepository]?
    var repositoriesAdmin : [PARepository]?
    var dateJoined : Date?
    var email : String = ""
    
    var repositoriesCreated : Int?
    var totalRepositoriesJoined : Int?
    var storiesUploaded : Int?
    var photosUploaded : Int?
    
    
    
}

extension Dictionary where Key == String {
    
    func getStringValue( k : String, defaultValue : String? = "") -> String {
        
        if let ret_val = self[k] as? String {
            return ret_val
        }
        
        return defaultValue!
    }
    
    func getFirebaseDateValue( k : String) -> Date {
        
        
        if let date_str = self[k] as? String {
            
            let date_val = PADateManager.sharedInstance.getDateFromString(str: date_str, formatType: .FirebaseFull)
            
            return date_val
        }
        
        return Date()
    }
    
    func getIntValue( k : String, defaultValue : Int? = 0 ) -> Int {
        
        if let ret_val = self[k] as? Int {
            return ret_val
        }
        
        return defaultValue!
    }
}
extension PAUser {
    
    static func UserWithSnapshot( snap : FIRDataSnapshot ) -> PAUser? {
        
        guard let snapData = snap.value as? Dictionary<String,AnyObject> else { return nil }
        
        
        let n = PAUser()
        
        n.uid                   = snapData.getStringValue(k: Keys.User.uid)
        n.firstName             = snapData.getStringValue(k: Keys.User.firstName)
        n.lastName              = snapData.getStringValue(k: Keys.User.lastName)
        n.profileImageURL       = snapData.getStringValue(k: Keys.User.profileMainURL)
        n.profileThumbImageURL  = snapData.getStringValue(k: Keys.User.profileThumbURL)
        n.email                 = snapData.getStringValue(k: Keys.User.email)
        
        
        n.totalRepositoriesJoined   = snapData.getIntValue(k: Keys.User.repositoriesJoined)
        n.repositoriesCreated       = snapData.getIntValue(k: Keys.User.repositoriesCreated)
        n.photosUploaded            = snapData.getIntValue(k: Keys.User.photosUploaded)
        n.storiesUploaded           = snapData.getIntValue(k: Keys.User.storiesUploaded)
        
        n.dateJoined    = snapData.getFirebaseDateValue(k: Keys.User.dateJoined)
        //n.birthDate     = snapData.getFirebaseDateValue(k: Keys.User.birthDate)
        
        return n
    }
}

extension PAUser {
    var repositoriesJoinedString : String {
        get {
            if let t = self.totalRepositoriesJoined {
                return String(t)
            }
            else {
                return "0"
            }
        }
    }
    
    var repositoriesCreatedString : String {
        get {
            if let t = self.repositoriesCreated {
                return String(t)
            }
            
            return "0"
        }
    }
    
    var photosUploadedString : String {
        get {
            if let t = self.photosUploaded {
                return String(t)
            }
            
            return "0"
        }
    }
    
    var storiesUploadedString : String {
        get {
            if let t = self.storiesUploaded {
                return String(t)
            }
            
            return "0"
        }
    }
    
    var fullNameString : String {
        get {
            return String.init(format: "%@ %@", self.firstName, self.lastName)
        }
    }
}
