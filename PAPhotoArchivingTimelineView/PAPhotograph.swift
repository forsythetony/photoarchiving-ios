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
import Kingfisher


struct PAPhotographiOSInformation {
    
    var degreesDelta : CLLocationDegrees = 4.0
}
class PAPhotograph {
    
    fileprivate static let DEFAULT_UID                      = ""
    fileprivate static let DEFAULT_TITLE                    = ""
    fileprivate static let DEFAULT_LONG_DESCRIPTION         = ""
    fileprivate static let DEFAULT_DATE_UPLOADED            = Date()
    fileprivate static let DEFAULT_THUMB_URL                = ""
    fileprivate static let DEFAULT_MAIN_URL                 = ""
    fileprivate static let DEFAULT_DATE_TAKEN               = Date()
    fileprivate static let DEFAULT_DATE_CONF : Float        = 0.0
    fileprivate static let DEFAULT_LOC_LONGITUDE : CGFloat  = 0.0
    fileprivate static let DEFAULT_LOC_LATITUDE : CGFloat   = 0.0
    fileprivate static let DEFAULT_LOC_STREET               = "Any Street"
    fileprivate static let DEFAULT_LOC_ZIP                  = "Any ZIP"
    fileprivate static let DEFAULT_LOC_CITY                 = "Any City"
    fileprivate static let DEFAULT_LOC_STATE                = "Any State"
    fileprivate static let DEFAULT_LOC_COUNTRY              = "Any Country"
    fileprivate static let DEFAULT_LOC_CONF : Float         = 0.0
    fileprivate static let DEFAULT_UPLOADER_ID              = ""
    
    var uid : String = "" {
        didSet {
            self.didSetImageUUID()
        }
    }
    var title = ""
    var longDescription = ""
    var uploadedBy : PAUser?
    var dateUploaded : Date?
    var thumbnailURL : String = ""
    var thumbnailImage : UIImage?
    var mainImageURL = ""
    var mainImage : UIImage?
    var taggedPeople : [PAPerson]?
    var stories : [PAStory] = [PAStory]()
    var dateTaken : Date?
    var dateTakenConf : Float = 0.0
    var locationTaken : PALocation = PALocation()
    var locationTakenConf : Float = 0.0
    var localImageURL : URL?
    var uploaderID : String?
    var hasThumbnail = false
    var iosData : PAPhotographiOSInformation = PAPhotographiOSInformation()
    
    var delegate : PAPhotographDelegate?
    
    
    func didSetImageUUID() {
        if self.hasThumbnail {
            if self.thumbnailURL != "" {
                return
            }
        }
        
        guard self.uid != "" else { return }
        
        let storage_ref_url = String.init(format: "images/thumb_%@", self.uid)
        let storage_ref = FIRStorage.storage().reference(withPath: storage_ref_url)
        let db_ref = FIRDatabase.database().reference(withPath: "/photographs").child(self.uid)
        
        storage_ref.downloadURL { (download_url, error) in
            
            if let error = error {
                let error_message = String.init(format: "\nError dowloading thumbnail image for photo with uid-> %@ and thumbnail storage url -> %@", self.uid, storage_ref_url)
                
                print( error_message )
                return
            }
            
            print("\nGot a thumbnail image for \(self.uid)\n")
            
            self.hasThumbnail = true
            db_ref.child(Keys.Photograph.hasThumbnail).setValue("true")
            db_ref.child(Keys.Photograph.thumbURL).setValue(download_url!.absoluteString)
            
        }
        
    }
    /// Function Name:  fetchStories
    /// 
    /// Return Value:   Void
    /// 
    /// Description:    This function will pull all the stories for this photograph from
    ///                 Firebase and alert the delegate upon each new story addition
    ///
    func fetchStories() {
        
        self.stories.removeAll()
        
        let db_ref = FIRDatabase.database().reference()
        
        let curr_photo_ref = db_ref.child("photographs").child(self.uid)
        
        let stories_ref = curr_photo_ref.child("stories")
        
        stories_ref.observe(.childAdded, with: { snapshot in
            
            
            
            db_ref.child("stories").child(snapshot.key).observeSingleEvent(of: .value, with: { (snapper) in
                
                if let new_story = PAStory.storyFromSnapshot(snapshot: snapper ) {
                    
                    self.stories.append(new_story)
                    self.delegate?.PAPhotographDidFetchNewStory(story: new_story)
                    
                }
            })
            
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
        
        //  Upload Information
        if let date_uploaded = snapData[Keys.Photograph.dateUploaded] as? String {
            newPhoto.dateUploaded = PADateManager.sharedInstance.getDateFromString(str: date_uploaded, formatType: .FirebaseFull)
        }
        else {
            newPhoto.dateUploaded = PAPhotograph.DEFAULT_DATE_UPLOADED
        }
        
        newPhoto.uploaderID = snapData[Keys.Photograph.uploaderID] as? String ?? PAPhotograph.DEFAULT_UPLOADER_ID
        
        
        if let date_taken = snapData[Keys.Photograph.dateTaken] as? String {
            
            newPhoto.dateTaken = PADateManager.sharedInstance.getDateFromString(str: date_taken, formatType: .FirebaseFull)
        }
        else {
            newPhoto.dateTaken = PAPhotograph.DEFAULT_DATE_TAKEN
            newPhoto.dateTakenConf = 0.0
        }
        
        newPhoto.mainImageURL = snapData[Keys.Photograph.mainURL] as? String ?? PAPhotograph.DEFAULT_MAIN_URL
        
        if let has_thumb_str = snapData[Keys.Photograph.hasThumbnail] as? String {
            
            newPhoto.hasThumbnail = has_thumb_str.boolValue
        }
        else {
            newPhoto.hasThumbnail = false
        }
        /*
            If there is no thumbnail URL then just use the main URL
            as the thumbnail URL
        */
        if snapData[Keys.Photograph.thumbURL] == nil {
            newPhoto.thumbnailURL = newPhoto.mainImageURL
        }
        else {
            newPhoto.thumbnailURL = (snapData[Keys.Photograph.thumbURL] as? String)!
        }
        
        
        let location = PALocation()
        
        let lattitude = snapData[Keys.Photograph.locationLatitude]         as? CGFloat ?? PAPhotograph.DEFAULT_LOC_LATITUDE
        let longitude = snapData[Keys.Photograph.locationLongitude]         as? CGFloat ?? PAPhotograph.DEFAULT_LOC_LONGITUDE
        let location_city = snapData[Keys.Photograph.locationCity]          as? String ?? PAPhotograph.DEFAULT_LOC_CITY
        let location_state = snapData[Keys.Photograph.locationState]        as? String ?? PAPhotograph.DEFAULT_LOC_STATE
        let location_country = snapData[Keys.Photograph.locationCountry]    as? String ?? PAPhotograph.DEFAULT_LOC_COUNTRY
        
        let location_zip = snapData[Keys.Photograph.locationZIP] as? String ?? PAPhotograph.DEFAULT_LOC_ZIP
        
        if lattitude != PAPhotograph.DEFAULT_LOC_LATITUDE && longitude != PAPhotograph.DEFAULT_LOC_LONGITUDE {
            location.coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(lattitude), longitude: CLLocationDegrees(longitude))
            
        }
        else {
            location.coordinates = nil
        }
        
        location.city       = location_city
        location.state      = location_state
        location.country    = location_country
        
        newPhoto.locationTaken = location
        
        newPhoto.locationTakenConf = snapData[Keys.Photograph.locationConf] as? Float ?? PAPhotograph.DEFAULT_LOC_CONF
        
        if let degreesDelta = snapData[Keys.Photograph.iosData]?[Keys.Photograph.iOS.mapDegreesDelta] as? CLLocationDegrees {
            newPhoto.iosData.degreesDelta = degreesDelta
        }
        
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
        
        //  Date Uploaded
        if let date_uploaded = self.dateUploaded {
            let date_uploaded_string = PADateManager.sharedInstance.getDateString(date: date_uploaded, formatType: .FirebaseFull)
            
            jsonArray[Keys.Photograph.dateUploaded] = date_uploaded_string
        }
        
        //  Uploader ID
        jsonArray[Keys.Photograph.uploaderID] = self.uploaderID
        
        
        let locationData = self.locationTaken
        
        jsonArray[Keys.Photograph.locationCity]         = locationData.city
        jsonArray[Keys.Photograph.locationState]        = locationData.state
        jsonArray[Keys.Photograph.locationCountry]      = locationData.country
        jsonArray[Keys.Photograph.locationLatitude]     = locationData.coordinates?.latitude ?? PAPhotograph.DEFAULT_LOC_LATITUDE
        jsonArray[Keys.Photograph.locationLongitude]    = locationData.coordinates?.longitude ?? PAPhotograph.DEFAULT_LOC_LONGITUDE
        jsonArray[Keys.Photograph.locationConf]         = self.locationTakenConf
        
//        
//        if let locationData = self.locationTaken {
//            jsonArray[Keys.Photograph.locationCity]         = locationData.city
//            jsonArray[Keys.Photograph.locationState]        = locationData.state
//            jsonArray[Keys.Photograph.locationCountry]      = locationData.country
//            jsonArray[Keys.Photograph.locationLatitude]     = locationData.coordinates?.latitude ?? PAPhotograph.DEFAULT_LOC_LATITUDE
//            jsonArray[Keys.Photograph.locationLongitude]    = locationData.coordinates?.longitude ?? PAPhotograph.DEFAULT_LOC_LONGITUDE
//            jsonArray[Keys.Photograph.locationConf]         = self.locationTakenConf
//        }
//        else {
//            jsonArray[Keys.Photograph.locationCity]         = PAPhotograph.DEFAULT_LOC_CITY
//            jsonArray[Keys.Photograph.locationState]        = PAPhotograph.DEFAULT_LOC_STATE
//            jsonArray[Keys.Photograph.locationCountry]      = PAPhotograph.DEFAULT_LOC_COUNTRY
//            jsonArray[Keys.Photograph.locationLatitude]     = PAPhotograph.DEFAULT_LOC_LATITUDE
//            jsonArray[Keys.Photograph.locationLongitude]    = PAPhotograph.DEFAULT_LOC_LONGITUDE
//            jsonArray[Keys.Photograph.locationConf]         = self.locationTakenConf
//        }
//        
        
        jsonArray[Keys.Photograph.hasThumbnail] = self.hasThumbnail.PAFirebaseValue
        jsonArray[Keys.Photograph.iosData] = [
            Keys.Photograph.iOS.mapDegreesDelta : self.iosData.degreesDelta
        ]
        
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
        
        let locationInfo = PAPhotoInfoLocation(_uuid: self.uid, _title: self.title, _type: .Location, _cityName: self.locationTaken.city, _stateName: self.locationTaken.state, _coordinates: self.locationTaken.coordinates ?? CLLocationCoordinate2D.defaultLocation, _confidence: 0.4)
        
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
    
    func getPhotographCopy() -> PAPhotograph {
        
        let np = PAPhotograph()
        
        np.uid = self.uid
        np.dateTaken = self.dateTaken
        np.dateTakenConf = self.dateTakenConf
        np.longDescription = self.longDescription
        np.locationTakenConf = self.locationTakenConf
        np.locationTaken = PALocation()
        np.locationTaken.coordinates = self.locationTaken.coordinates
        
        return np
    }
    
    var hasLocation : Bool {
        get {
            return self.locationTaken.coordinates != nil
        }
    }
    
    var locationState : String? {
        get {
            if self.locationTaken.state != PAPhotograph.DEFAULT_LOC_STATE {
                return self.locationTaken.state
            }
            
            return nil
        }
    }
    
    var locationZIP : String? {
        if self.locationTaken.zip != PAPhotograph.DEFAULT_LOC_ZIP {
            return self.locationTaken.zip
        }
        
        return nil
    }
    
    var locationCity : String? {
        if self.locationTaken.city != PAPhotograph.DEFAULT_LOC_CITY {
            return self.locationTaken.city
        }
        
        return nil
    }
    
    var locationCountry : String? {
        if self.locationTaken.country != PAPhotograph.DEFAULT_LOC_COUNTRY {
            return self.locationTaken.country
        }
        
        return nil
    }
}
