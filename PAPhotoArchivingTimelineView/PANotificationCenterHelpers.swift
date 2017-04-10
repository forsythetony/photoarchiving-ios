//
//  PANotificationCenterHelpers.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/5/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

extension NotificationCenter {
    
    func PARemoveAllNotificationsWithName( listener : Any, names : [Notification.Name] ) {
        
        for n in names {
            
            self.removeObserver(listener, name: n, object: nil)
        }
    }
}
