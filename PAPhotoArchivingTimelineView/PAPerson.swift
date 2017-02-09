//
//  PAPerson.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

class PAPerson {
    
    var uid         = ""
    var firstName   = ""
    var lastName    = ""
    
    var birthDate       : Date?
    var birthDateConf   : Float = 0.0
    var deathDate       : Date?
    var deathDateConf   : Float = 0.0
    
    var profileImageURL = ""
    
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
}
