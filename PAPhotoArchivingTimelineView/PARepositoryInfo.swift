//
//  PARepositoryInfo.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 10/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation

protocol PADescriptor {
    
    func JSONStringDescriptor() -> String
}
//  MARK: Main Definition

struct PAKeys {
    
    struct PhotographInfo {
        static let UUID = "UUID"
        static let Title = "Title"
        static let ThumbnailURL = "ThumbnailURL"
        static let MainImageURL = "MainImageURL"
        static let DateTaken = "DateTaken"
        static let DateTakenConf = "DateTakenConf"
    }
}
public class PAPhotographInfo {
    
    var UUID : String?
    var Title : String?
    var ThumbnailURL : String?
    var MainImageURL : String?
    var DateTaken : Date?
    var DateTakenConf : Float?
    
}

extension PAPhotographInfo {
    
    static var MockPhoto1 : PAPhotographInfo {
        
        get {
            let uid = PARandom.string()
            let title = PARandom.string()
            let thumbnailurl = "https://s3-us-west-2.amazonaws.com/node-photo-archive/mainPhotos/Fred_and_Freddie.jpg"
            let mainImageUrl = PARandom.string()
            let dateTaken = PADateManager.sharedInstance.randomDateBetweenYears(startYear: 1905, endYear: 1930)
            let dateTakenConf = Float(0.6)
            
            let newPhoto = PAPhotographInfo()
            
            newPhoto.UUID = uid
            newPhoto.Title = title
            newPhoto.ThumbnailURL = thumbnailurl
            newPhoto.MainImageURL = mainImageUrl
            newPhoto.DateTaken = dateTaken
            newPhoto.DateTakenConf = dateTakenConf
        
            return newPhoto
        }
    }
    
}

extension PAPhotographInfo : PADescriptor {
    
    func JSONStringDescriptor() -> String {
        
        let information = PAInformationDictionary()
        
        information.insert(stringValue: self.UUID, forKey: PAKeys.PhotographInfo.UUID)
        information.insert(stringValue: self.Title, forKey: PAKeys.PhotographInfo.Title)
        information.insert(stringValue: self.ThumbnailURL, forKey: PAKeys.PhotographInfo.ThumbnailURL)
        information.insert(stringValue: self.MainImageURL, forKey: PAKeys.PhotographInfo.MainImageURL)
        information.insert(dateValue: self.DateTaken, forKey: PAKeys.PhotographInfo.DateTaken)
        information.insert(floatValue: self.DateTakenConf, forKey: PAKeys.PhotographInfo.DateTakenConf)
        
        return information.getStringDescriptor()
    }
}


public class PARepositoryInfo {
    
    var UUID        : String?
    var Title       : String?
    var Description : String?
    var StartDate   : Date?
    var EndDate     : Date?
    var Photographs : [PAPhotographInfo]?
}

extension PARepositoryInfo {
    
}
extension PARepositoryInfo : PADescriptor {
    
    func JSONStringDescriptor() -> String {
        
        var information = [String : String]()
        let notAvailable = "n/a"
        
        if let uid = self.UUID {
            information["UUID"] = uid
        } else {
            information["UUID"] = notAvailable
        }
        
        
        if let title = self.Title {
            information["title"] = title
        } else {
            information["title"] = notAvailable
        }
        
        if let description = self.Description {
            information["description"] = description
        } else {
            information["description"] = notAvailable
        }
        
        if let startDate = self.StartDate {
            information["startDate"] = PADateManager.sharedInstance.getDateString(date: startDate, formatType: .Pretty)
        } else {
            information["startDate"] = notAvailable
        }
        
        if let endDate = self.EndDate {
            information["endDate"] = PADateManager.sharedInstance.getDateString(date: endDate, formatType: .Pretty)
        } else {
            information["endDate"] = notAvailable
        }
        
        return information.description
    }
}
extension PARepositoryInfo {
    
    static var MockRepo1 : PARepositoryInfo {
        get {
            let uid = PARandom.string()
            let title = "Mock 1 Repo"
            let description = "The is just a mock repo"
            
            let startDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1903)
            let endDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1933)
            
            let newRepo = PARepositoryInfo()
            
            newRepo.UUID = uid
            newRepo.Title = title
            newRepo.Description = description
            newRepo.StartDate = startDate
            newRepo.EndDate = endDate
            
            return newRepo
        }
    }

    
    func populateMockPhotos() {
        
        self.Photographs = [PAPhotographInfo]()
        
        let newPhoto = PAPhotographInfo.MockPhoto1
        
        self.Photographs?.append(newPhoto)
    }
    
}
//  MARK: Extensions
