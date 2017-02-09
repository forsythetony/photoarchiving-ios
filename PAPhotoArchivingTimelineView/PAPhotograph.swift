//
//  PAPhotograph.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

class PAPhotograph {
    
    private static let DEFAULT_UID                      = ""
    private static let DEFAULT_TITLE                    = ""
    private static let DEFAULT_LONG_DESCRIPTION         = ""
    private static let DEFAULT_DATE_UPLOADED            = Date()
    private static let DEFAULT_THUMB_URL                = ""
    private static let DEFAULT_MAIN_URL                 = ""
    private static let DEFAULT_DATE_TAKEN               = Date()
    private static let DEFAULT_DATE_CONF : Float        = 0.0
    private static let DEFAULT_LOC_LONGITUDE : CGFloat  = 0.0
    private static let DEFAULT_LOC_LATITUDE : CGFloat   = 0.0
    private static let DEFAULT_LOC_STREET               = "Any Street"
    private static let DEFAULT_LOC_CITY                 = "Any City"
    private static let DEFAULT_LOC_STATE                = "Any State"
    private static let DEFAULT_LOC_COUNTRY              = "Any Country"
    private static let DEFAULT_LOC_CONF : Float         = 0.0
    
    var uid = ""
    var title = ""
    var longDescription = ""
    var uploadedBy : PAUser?
    var dateUploaded : Date?
    var thumbnailURL = ""
    var thumbnailImage : UIImage?
    var mainImageURL = ""
    var mainImage : UIImage?
    var taggedPeople : [PAPerson]?
    var stories : [PAStory] = [PAStory]()
    var dateTaken : Date?
    var dateTakenConf : Float = 0.0
    var locationTaken : PALocation?
    var locationTakenConf : Float = 0.0
    
    var delegate : PAPhotographDelegate?
    
    
    
    /// Function Name:  fetchStories
    /// 
    /// Return Value:   Void
    /// 
    /// Description:    This function will pull all the stories for this photograph from
    ///                 Firebase and alert the delegate upon each new story addition
    ///
    func fetchStories() {
        
        let db_ref = FIRDatabase.database().reference()
        
        let curr_photo_ref = db_ref.child("photographs").child(self.uid)
        
        let stories_ref = curr_photo_ref.child("stories")
        
        stories_ref.observe(.childAdded, with: { snapshot in
            
            if let new_story = PAStory.storyFromSnapshot(snapshot: snapshot ) {
                
                self.stories.append(new_story)
                self.delegate?.PAPhotographDidFetchNewStory(story: new_story)
                
            }
        })
    }
    
    /// Function Name:  photographWithSnapshot
    ///
    /// Parameter 'snap':   The FIRDataSnapshot used to create the instance
    ///
    /// Return Value:       An instance of PAPhotograph created from the FIRDataSnapshot
    ///                     or nil if no instance could be created
    ///
    static func photographWithSnapshot( snap : FIRDataSnapshot ) -> PAPhotograph? {
        
        guard let snapData = snap.value as? Dictionary<String, AnyObject> else { return nil }
        
        let newPhoto = PAPhotograph()
        
        newPhoto.title = snapData[Keys.Photograph.title] as? String ?? PAPhotograph.DEFAULT_TITLE
        
        newPhoto.longDescription = snapData[Keys.Photograph.description] as? String ?? PAPhotograph.DEFAULT_LONG_DESCRIPTION
        
        newPhoto.uid = snap.key
        
        newPhoto.dateTakenConf = snapData[Keys.Photograph.dateTakenConf] as? Float ?? PAPhotograph.DEFAULT_DATE_CONF
        
        if let date_taken = snapData[Keys.Photograph.dateTaken] as? String {
            
            newPhoto.dateTaken = PADateManager.sharedInstance.getDateFromString(str: date_taken, formatType: .FirebaseFull)
        }
        else {
            newPhoto.dateTaken = PAPhotograph.DEFAULT_DATE_TAKEN
            newPhoto.dateTakenConf = 0.0
        }
        
        newPhoto.mainImageURL = snapData[Keys.Photograph.mainURL] as? String ?? PAPhotograph.DEFAULT_MAIN_URL
        newPhoto.thumbnailURL = snapData[Keys.Photograph.thumbURL] as? String ?? PAPhotograph.DEFAULT_THUMB_URL
        
        
        let location = PALocation()
        
        let lattitude = snapData[Keys.Photograph.locationLatitude]         as? CGFloat ?? PAPhotograph.DEFAULT_LOC_LATITUDE
        let longitude = snapData[Keys.Photograph.locationLongitude]         as? CGFloat ?? PAPhotograph.DEFAULT_LOC_LONGITUDE
        let location_city = snapData[Keys.Photograph.locationCity]          as? String ?? PAPhotograph.DEFAULT_LOC_CITY
        let location_state = snapData[Keys.Photograph.locationState]        as? String ?? PAPhotograph.DEFAULT_LOC_STATE
        let location_country = snapData[Keys.Photograph.locationCountry]    as? String ?? PAPhotograph.DEFAULT_LOC_COUNTRY
        
        location.coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(lattitude), longitude: CLLocationDegrees(longitude))
        
        location.city       = location_city
        location.state      = location_state
        location.country    = location_country
        
        newPhoto.locationTaken = location
        
        return newPhoto
        
    }
    
    
    
    
    func PAGetJSONCompatibleArray() -> [String : Any] {
        
        var jsonArray = [String : Any]()
        
        
        //  UID
        jsonArray[Keys.Photograph.uid] = self.uid
        
        //  Title
        jsonArray[Keys.Photograph.title] = self.title
        
        //  Description
        jsonArray[Keys.Photograph.description] = self.longDescription
        
        //  Date Taken
        if let d = self.dateTaken {
            let dStr = PADateManager.sharedInstance.getDateString(date: d, formatType: .FirebaseFull)
            
            jsonArray[Keys.Photograph.dateTaken] = dStr
        }
        else {
            jsonArray[Keys.Photograph.dateTaken] = ""
        }
        
        //  Date Taken Confidence
        jsonArray[Keys.Photograph.dateTakenConf] = self.dateTakenConf
        
        //  Thumbnail URL
        jsonArray[Keys.Photograph.thumbURL] = self.thumbnailURL
        
        //  Main URL
        jsonArray[Keys.Photograph.mainURL] = self.mainImageURL
        
        if let locationData = self.locationTaken {
            jsonArray[Keys.Photograph.locationCity] = locationData.city
            jsonArray[Keys.Photograph.locationState] = locationData.state
            jsonArray[Keys.Photograph.locationCountry] = locationData.country
            jsonArray[Keys.Photograph.locationLatitude] = locationData.coordinates?.latitude ?? PAPhotograph.DEFAULT_LOC_LATITUDE
            jsonArray[Keys.Photograph.locationLongitude] = locationData.coordinates?.longitude ?? PAPhotograph.DEFAULT_LOC_LONGITUDE
            jsonArray[Keys.Photograph.locationConf] = self.locationTakenConf
        }
        else {
            jsonArray[Keys.Photograph.locationCity] = PAPhotograph.DEFAULT_LOC_CITY
            jsonArray[Keys.Photograph.locationState] = PAPhotograph.DEFAULT_LOC_STATE
            jsonArray[Keys.Photograph.locationCountry] = PAPhotograph.DEFAULT_LOC_COUNTRY
            jsonArray[Keys.Photograph.locationLatitude] = PAPhotograph.DEFAULT_LOC_LATITUDE
            jsonArray[Keys.Photograph.locationLongitude] = PAPhotograph.DEFAULT_LOC_LONGITUDE
            jsonArray[Keys.Photograph.locationConf] = self.locationTakenConf
        }
        
        return jsonArray
    }
    
    
    
}

protocol PAPhotographDelegate {
    func PAPhotographDidFetchNewStory( story : PAStory )
}


//  An extension to get an array of useful chunks
//  of data
extension PAPhotograph {
    
    func getPhotoInfoData() -> [AnyObject] {
        var info : [AnyObject] = [AnyObject]()
        
        let titleInfo = PAPhotoInfoText(_uuid: self.uid, _title: "Title", _mainText: self.title, _supplementaryText: "", _type: .Text)
        
        info.append(titleInfo)
        
        
        let dateTakenInfo = PAPhotoInfoDate(    _uid: self.uid,
                                                _title: "Date Taken",
                                                _type: .Date,
                                                _dateTaken: self.dateTaken,
                                                _dateTakenConf: self.dateTakenConf,
                                                _dateTakenString: PADateManager.sharedInstance.getDateString(date: (self.dateTaken ?? Date()),
                                                                                                             formatType: .Pretty))
        
        info.append(dateTakenInfo)
        
        let locationInfo = PAPhotoInfoLocation(_uuid: self.uid, _title: self.title, _type: .Location, _cityName: (self.locationTaken?.city)!, _stateName: (self.locationTaken?.state)!, _coordinates: (self.locationTaken?.coordinates!)!, _confidence: 0.4)
        
        info.append(locationInfo)
        
        
        return info
    }
}

//  For creating a mock photograph
extension PAPhotograph {
    
    static func Mock1() -> PAPhotograph {
        
        let newPhoto = PAPhotograph()
        
        newPhoto.uid = UUID().uuidString
        
        newPhoto.dateTaken = PADateManager.sharedInstance.getDateFromYearInt(year: 1922)
        newPhoto.dateTakenConf = 0.8
        newPhoto.dateUploaded = Date.dateBySubtractingDays(days: 600)
        newPhoto.longDescription = "What a day to be out!"
        newPhoto.title = "A day at the park"
        newPhoto.thumbnailURL = "https://www.chrishair.co.uk/assets/images/fifa/bayern-munchen.png"
        newPhoto.mainImageURL = "https://www.chrishair.co.uk/assets/images/fifa/bayern-munchen.png"
        
        let location = PALocation()
        location.city = "St. Louis"
        location.state = "Missouri"
        location.country = "U.S.A."
        location.zip = "63144"
        location.coordinates = CLLocationCoordinate2D(latitude: 38.6011179, longitude: -90.3681826)
        
        newPhoto.locationTaken = location
        
        let uploader = PAUser()
        
        uploader.dateJoined = Date.dateBySubtractingYears(years: 3)
        uploader.dateLastLoggedIn = Date.dateBySubtractingDays(days: 10)
        uploader.birthDate = Date.dateBySubtractingYears(years: 21)
        uploader.firstName = "Anthony"
        uploader.lastName = "F"
        uploader.profileImageURL = "http://i.imgur.com/0o3i6of.jpg"
        
        newPhoto.uploadedBy = uploader
        
        return newPhoto
    }
    
    static func Mock2() -> PAPhotograph {
        let newPhoto = PAPhotograph()
        
        newPhoto.uid = UUID().uuidString
        
        newPhoto.dateTaken = PADateManager.sharedInstance.getDateFromYearInt(year: 1922)
        newPhoto.dateTakenConf = 0.8
        newPhoto.dateUploaded = Date.dateBySubtractingDays(days: 600)
        newPhoto.longDescription = "What a day to be out!"
        newPhoto.title = "A day at the park"
        
        newPhoto.thumbnailImage = #imageLiteral(resourceName: "thumb_image_test")
        newPhoto.mainImage = #imageLiteral(resourceName: "main_image_test")
        
        let location = PALocation()
        location.city = "St. Louis"
        location.state = "Missouri"
        location.country = "U.S.A."
        location.zip = "63144"
        location.coordinates = CLLocationCoordinate2D(latitude: 38.6011179, longitude: -90.3681826)
        
        newPhoto.locationTaken = location
        
        let uploader = PAUser()
        
        uploader.dateJoined = Date.dateBySubtractingYears(years: 3)
        uploader.dateLastLoggedIn = Date.dateBySubtractingDays(days: 10)
        uploader.birthDate = Date.dateBySubtractingYears(years: 21)
        uploader.firstName = "Anthony"
        uploader.lastName = "F"
        uploader.profileImageURL = "http://i.imgur.com/0o3i6of.jpg"
        
        newPhoto.uploadedBy = uploader
        
        return newPhoto
    }
}

//  Logger extension
extension PAPhotograph {
    
    var PADescription : String {
        get {
            let objectLogger = PAObjectLogger()
            
            objectLogger.title = "PAPhotograph Description"
            
            //  UID
            objectLogger.addStringWithTitle(title: "UID", value: self.uid)
            
            //  Title
            objectLogger.addStringWithTitle(title: "Title", value: self.title)
            
            //  Long Description
            objectLogger.addStringWithTitle(title: "Long Description", value: self.longDescription)
            
            //  Date Uploaded
            objectLogger.addDateWithTitle(title: "Date Taken", val: self.dateTaken)
            
            //  Thumbnail URL
            objectLogger.addStringWithTitle(title: "Thumbnail URL", value: self.thumbnailURL)
            
            //  Main URL
            objectLogger.addStringWithTitle(title: "Main URL", value: self.mainImageURL)
            
            return objectLogger.getLogString()
        }
    }
}

extension PAPhotograph {
    
    
}
