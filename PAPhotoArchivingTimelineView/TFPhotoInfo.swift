//
//  PAPhotoInfo.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

enum PAPhotoInfoType {
    case Text
    case LongText
    case Date
    case Location
    case TaggedPeople
    case Submitter
    case Unknown
}

class PAPhotoInfo  {
    
    var title = ""
    var uid = ""
    var type : PAPhotoInfoType = PAPhotoInfoType.Unknown
    
    init(_title : String, _uid : String, _type : PAPhotoInfoType) {
        self.title  = _title
        self.uid    = _uid
        self.type   = _type
    }
}

class PAPhotoInfoText : PAPhotoInfo {
    var mainText = ""
    var supplementaryText = ""
    
    
    init(_uuid : String, _title : String, _mainText : String, _supplementaryText : String, _type : PAPhotoInfoType) {
        
        super.init(_title: _title, _uid: _uuid, _type: _type)
        
        self.mainText = _mainText
        self.supplementaryText = _supplementaryText
    }
}

class PAPhotoInfoLocation : PAPhotoInfo {
    var cityName = ""
    var stateName = ""
    var coordinates : CLLocationCoordinate2D?
    var confidence : Float = 0.0
    
    init(_uuid : String, _title : String, _type : PAPhotoInfoType, _cityName : String, _stateName : String, _coordinates : CLLocationCoordinate2D, _confidence : Float) {
        super.init(_title: _title, _uid: _uuid, _type: _type)
        
        self.cityName = _cityName
        self.stateName = _stateName
        self.coordinates = _coordinates
        self.confidence = _confidence
    }
}

class PAPhotoInfoDate : PAPhotoInfo {
    
    var dateTaken : Date?
    var dateTakenConf : Float = 0.0
    var dateTakenString = ""
    
    init(_uid : String, _title : String, _type : PAPhotoInfoType, _dateTaken : Date?, _dateTakenConf : Float, _dateTakenString : String) {
        super.init(_title: _title, _uid: _uid, _type: _type)
        
        self.dateTaken = _dateTaken
        self.dateTakenConf = _dateTakenConf
        self.dateTakenString = _dateTakenString
        
    }
}

class PAPhotoInfoAddedBy : PAPhotoInfo {
    
    var submitter : PAPerson?
    var dateSubmitted : Date?
}
