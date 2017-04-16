//
//  PANavigationManager.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/6/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation


enum PANavigationPages : String {
    case home               = "Home"
    case repositories       = "Repositories"
    case myRepositories     = "My Repositories"
    case profile            = "My Profile"
    case people             = "People"
    case settings           = "Settings"
    case about              = "About"
    case unkown             = "Unknown"
}

class PANavigationManager {
    
    static let sharedInstance = PANavigationManager()
    
    let allPages = [
        PANavigationPages.home,
        PANavigationPages.repositories,
        PANavigationPages.myRepositories,
        PANavigationPages.people,
        PANavigationPages.profile,
        PANavigationPages.settings
        //PANavigationPages.about
        ]
    
    var currentIndex : Int = 0
    
    
    
    
    func updateCurrentIndex( page : PANavigationPages ) {
        
        if let ci = allPages.index(of: page) {
            currentIndex = ci
        }
    }
    
}
