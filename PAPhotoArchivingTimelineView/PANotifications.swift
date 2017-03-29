//
//  PANotifications.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/28/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

extension Notification {
    
    static func PABuildPhotoUploadNotification( status : PAUploadStatus, progress : Float, repo_id : String, photo_id : String) -> Notification {
        
        
        let user_info : [ String : Any ] = [
            Keys.NotificationUserInfo.PhotoUpload.photoID : photo_id,
            Keys.NotificationUserInfo.PhotoUpload.repoID : repo_id,
            Keys.NotificationUserInfo.PhotoUpload.status : status,
            Keys.NotificationUserInfo.PhotoUpload.progress : progress
        ]
        
        let notification = Notification(    name: Notification.Name(rawValue: Constants.Notifications.Upload.photoUploadProgressUpdate),
                                            object: nil,
                                            userInfo: user_info)
        
        return notification
    }
    
    static func PABuildPhotoUploadDidCompleteNotification( uploadInformation : PAPhotoUploadInformation ) -> Notification {
        
        let user_info : [ String : Any ] = [ Keys.NotificationUserInfo.PhotoUpload.photoUploadInformation : uploadInformation ]
        
        let notification = Notification(name: Notification.Name(rawValue: Constants.Notifications.Upload.photoUploadDidRemoveUpload), object: nil, userInfo: user_info)
        
        return notification
    }
    
    static func PABuildPhotoUploadWasAddedNotification( uploadInformation : PAPhotoUploadInformation ) -> Notification
    {
        let user_info : [ String : Any ] = [ Keys.NotificationUserInfo.PhotoUpload.photoUploadInformation : uploadInformation ]
        
        let notification = Notification(name: Notification.Name(rawValue: Constants.Notifications.Upload.photoUploadHasNewUpload), object: nil, userInfo: user_info)
        
        return notification
    }
}
