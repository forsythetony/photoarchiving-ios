//
//  PARepository.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/9/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol PARepositoryDelegate {
    
    func PARepositoryDidAddPhotographToRepository( new_photograph : PAPhotograph ) -> Void
    
}

fileprivate struct PARepoDefaults {
    
    static let uid = ""
    static let title = ""
    static let shortDescription = ""
    static let longDescription = ""
    static let thumbnailURL = ""
    static let creatorID = ""
    static let startDateInt : Int = 1900
    static let endDateInt : Int = 2000
    static let dateCreated = Date()
}
class PARepository {
    
    var uid                 = ""
    var title               = ""
    var shortDescription    = ""
    var longDescription     = ""
    var thumbnailURL        = ""
    var photographs         = [PAPhotograph]()
    
    var dateCreated = Date()
    
    var creatorID           = ""
    var thumbnailImage      : UIImage?
    var administrator       : PAUser?
    var startDate           : Date?
    var endDate             : Date?
    
    private var ref         : FIRDatabaseReference!
    private var photos      : [FIRDataSnapshot]! = []
    private var storageRef  : FIRStorageReference!
    fileprivate var refHandle: FIRDatabaseHandle!
    
    var delegate : PARepositoryDelegate?
    
    func configPhotographs() {

        let repo_ref = FIRDatabase.database().reference().child("repositories/" + self.uid + "/photos")
        
        let photos_ref = FIRDatabase.database().reference().child("photographs")
        
        repo_ref.observe(.childAdded, with: { snapshot in
         

            photos_ref.child(snapshot.key).observe(.value, with: { snapper in
                
                let new_photo_key = snapshot.key
                
                var exists = false
                
                for val in self.photographs {
                    
                    if val.uid == new_photo_key {
                        exists = true
                        break
                    }
                }
                if exists {
                    return
                }
                
                let new_photo = PAPhotograph.photographWithSnapshot(snap: snapper) ?? PAPhotograph.Mock1()
                
                self.photographs.append(new_photo)
                
                //  Alert the delegate (if there is one) that a new photograph was
                //  added to the repository
                self.delegate?.PARepositoryDidAddPhotographToRepository(new_photograph: new_photo)
        })
        
            
        })
        
    }
}

extension PARepository {
    
    func GetJSONCompatibleArray() -> [ String : Any ] {
        
        var json_array = [ String : Any ]()
        
        
        //  UID
        json_array[Keys.Repository.uid] = self.uid
        
        //  Title
        json_array[Keys.Repository.title] = self.title 
        
        //  Uploader Information
        json_array[Keys.Repository.creationDate] = PADateManager.sharedInstance.getDateString(date: self.dateCreated, formatType: .FirebaseFull)
        json_array[Keys.Repository.creatorID] = self.creatorID
        
        //  Start and End Dates
        if let start_date = self.startDate {
            let start_date_string = PADateManager.sharedInstance.getDateString(date: start_date, formatType: .FirebaseFull)
            json_array[Keys.Repository.startDate] = start_date_string
        }
        else {
            let default_start_date = PADateManager.sharedInstance.getDateFromYearInt(year: PARepoDefaults.startDateInt)
            let default_start_date_string = PADateManager.sharedInstance.getDateString(date: default_start_date, formatType: .FirebaseFull)
            
            json_array[Keys.Repository.startDate] = default_start_date_string
        }
        
        if let end_date = self.endDate {
            
            let end_date_string = PADateManager.sharedInstance.getDateString(date: end_date, formatType: .FirebaseFull)
            
            json_array[Keys.Repository.endDate] = end_date_string
        }
        else {
            let default_end_date = PADateManager.sharedInstance.getDateFromYearInt(year: PARepoDefaults.endDateInt)
            let default_end_date_string = PADateManager.sharedInstance.getDateString(date: default_end_date, formatType: .FirebaseFull)
            
            json_array[Keys.Repository.endDate] = default_end_date_string
        }
        
        
        //  Thumbnail URL
        json_array[Keys.Repository.thumbnailURL] = self.thumbnailURL
        
        //  Descriptions
        json_array[Keys.Repository.shortDescription] = self.shortDescription
        json_array[Keys.Repository.longDescription] = self.longDescription
        
        return json_array
    }
}
extension PARepository {
    
    static func CreateWithFirebaseSnapshot( snap : FIRDataSnapshot ) -> PARepository? {
        
        guard let snap_value = snap.value as? Dictionary<String, AnyObject> else { return nil }
        
        let newRepo = PARepository()
        
        
        if let title = snap_value[Keys.Repository.title] as? String {
            newRepo.title = title
        }
        
        if let shortDesc = snap_value[Keys.Repository.shortDescription] as? String {
            newRepo.shortDescription = shortDesc
        }
        
        if let longDesc = snap_value[Keys.Repository.longDescription] as? String {
            newRepo.longDescription = longDesc
        }
        
        if let thumb_url = snap_value[Keys.Repository.thumbnailURL] as? String {
            newRepo.thumbnailURL = thumb_url
        }
        
        if let start_date = snap_value[Keys.Repository.startDate] as? String {
            newRepo.startDate = PADateManager.sharedInstance.getDateFromString(str: start_date, formatType: .FirebaseFull)
        }
        
        if let end_date = snap_value[Keys.Repository.endDate] as? String {
            newRepo.endDate = PADateManager.sharedInstance.getDateFromString(str: end_date, formatType: .FirebaseFull)
        }
        
        newRepo.uid = snap.key
        
        return newRepo
        
    }
    
    
}
extension PARepository {
    
    static func Mock1() -> PARepository {
        
        let p = PARepository()
        
        p.uid = UUID().uuidString
        p.title = "Test Repo"
        p.shortDescription = "Hello"
        p.longDescription = "No way"
        p.thumbnailURL = "http://i.imgur.com/0o3i6of.jpg"
        p.startDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1903)
        p.endDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1943)
        
        
        return p
    }
    
    static func Mock2() -> PARepository {
        
        let p = PARepository()
        
        p.uid = "afssdkufhkusdhfskjfhksjhdf"
        p.title = "Test Repo"
        p.shortDescription = "Hello"
        p.longDescription = "No way"
        p.thumbnailURL = "http://i.imgur.com/0o3i6of.jpg"
        p.startDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1903)
        p.endDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1943)
        
        
        return p
    }
    
    func populatePhotographs() {
        
        let newPhotograph = PAPhotograph.Mock1()
        
        self.photographs.append(newPhotograph)
        
    }
}

//  Logging Description
extension PARepository {
    
    var PADescription : String {
        get {
            let objectLogger = PAObjectLogger()
            
            objectLogger.title = "PARepository Description"
            
            //  UID
            objectLogger.addStringWithTitle(title: "UID", value: self.uid)
            
            //  Title
            objectLogger.addStringWithTitle(title: "Repository Title", value: self.title)
            
            //  Short Description
            objectLogger.addStringWithTitle(title: "Short Description", value: self.shortDescription)
            
            //  Long Description
            objectLogger.addStringWithTitle(title: "Long Description", value: self.longDescription)
            
            //  Start Date
            objectLogger.addDateWithTitle(title: "Start Date", val: self.startDate)
            
            //  End Date
            objectLogger.addDateWithTitle(title: "End Date", val: self.endDate)
            
            //  Photos Count
            let photos_count = self.photographs.count
            
            objectLogger.addIntWithTitle(title: "Photos Count", val: photos_count)
            
            
            return objectLogger.getLogString()
        }
    }
}
