//
//  PADatabaseNotificaiton.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/9/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit
import Firebase

enum PADatabaseNotificationType : String {
    case photoAddedToRepository     = "photograph_added_to_repository"
    case userCreatedRepository      = "user_created_repository"
    case storyAddedToRepository     = "story_added_to_repository"
    case userAddedFriend            = "user_added_friend"
    case unknown                    = "unknown"
}

struct PADatabaseNotification {
    
    var notificationID      = ""
    var notificationType    = PADatabaseNotificationType.unknown
    var postingUserID       = ""
    var datePosted          = Date()
    var notificationData    = [ String : Any ]()
}

extension PADatabaseNotification {
    
    var jsonCompaitableArray : [ String : Any ] {
        get {
            var ret_array = [String : Any]()
            
            ret_array[Keys.DatabaseNotification.postingUserID] = postingUserID
            ret_array[Keys.DatabaseNotification.notificationType] = notificationType.rawValue
            ret_array[Keys.DatabaseNotification.datePosted] = PADateManager.sharedInstance.getDateString(date: datePosted, formatType: .FirebaseFull)
            
            ret_array[Keys.DatabaseNotification.notificationData] = notificationData
            
            return ret_array
        }
    }
    
    
    static func buildFromSnapshot( snapshot : FIRDataSnapshot ) -> PADatabaseNotification? {
        
        guard let snapValue = snapshot.value as? Dictionary<String, AnyObject> else { return nil }
        
        
        var newNotification = PADatabaseNotification()
        
        newNotification.datePosted = snapValue.getFirebaseDateValue(k: Keys.DatabaseNotification.datePosted)
        newNotification.notificationID = snapValue.getStringValue(k: Keys.DatabaseNotification.notificationID)
        newNotification.postingUserID = snapValue.getStringValue(k: Keys.DatabaseNotification.postingUserID)
        
        if let notification_type_value = snapValue[Keys.DatabaseNotification.notificationType] as? String {
            
            newNotification.notificationType = PADatabaseNotificationType.init(rawValue: notification_type_value) ?? .unknown
        }
        else {
            newNotification.notificationType = .unknown
        }
        
        if let notification_data = snapValue[Keys.DatabaseNotification.notificationData] as? [ String : Any ] {
            
            newNotification.notificationData = notification_data
        }
        
        
        return newNotification
    }
}
