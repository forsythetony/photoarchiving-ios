//
//  PACustomNotifications.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/3/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

protocol NotificationName {
    var name : Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self : NotificationName {
    var name : Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

enum Notifications : String, NotificationName {
    case didAddPhotograph
    case beganUploadingPhotograph
    case errorDeletingPhotograph
    case didDeletePhotograph
    
    case audioPlayerBarDidTapPlay
    case audioPlayerBarDidTapPause
    case audioPlayerBarDidTapStop
    
    case didUploadNewRepository
    
    case didDownloadProfileImage
    
    case didUpdateRepository
}

enum PhotoUploadStatus : String {
    
    case didUpload          = "Did Upload"
    case uploadFailed       = "Upload Failed"
    case beganUploading     = "Began Uploading"
    
}


enum PhotoDeleteStatus : String {
    
    case didDelete      = "Did Delete"
    case errorDeleting  = "Error Deleting"
    
}

struct NotificationKeys {
    
    struct PhotoUploaded {
        
        static let status   = "uploadStatus"
        static let photoID  = "photoID"
        static let error    = "uploadError"
    }
    
    struct PhotoDelete {
        
        static let status   = "deleteStatus"
        static let photoID  = "photoID"
        static let error    = "deleteError"
    }
}
