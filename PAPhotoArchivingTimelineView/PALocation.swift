//
//  PALocation.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import CoreLocation

class PALocation {
    var uid = ""
    var city = ""
    var street = ""
    var state = ""
    var zip = ""
    var country = ""
    var coordinates : CLLocationCoordinate2D?
    var shortDescription = ""
    var longDescription = ""
}
