//
//  Constants.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/8/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit

typealias Color = UIColor

struct Keys {
    
    
    struct Repository {
        static let shortDescription     = "shortDescription"
        static let longDescription      = "longDescription"
        static let thumbnailURL         = "thumbnailUrl"
        static let startDate            = "start_date"
        static let endDate              = "end_date"
        static let photographs          = "photos"
        static let title                = "title"
        static let uid                  = "uid"
        static let creationDate         = "creation_date"
        static let creatorID            = "creator_id"
    }
    
    
    struct Photograph {
        
        static let uid                  = "uid"
        static let description          = "description"
        static let mainURL              = "main_url"
        static let thumbURL             = "thumb_url"
        static let dateTaken            = "date_taken"
        static let title                = "title"
        static let dateTakenConf        = "date_taken_conf"
        static let locationLongitude    = "location_coord_longitude"
        static let locationLatitude     = "location_coord_lattitude"
        static let locationConf         = "location_conf"
        static let locationCity         = "location_city"
        static let locationCountry      = "location_country"
        static let locationState        = "location_state"
        static let localPhotoURL        = "local_photo_url"
        static let dateUploaded         = "date_uploaded"
        static let uploaderID           = "uploader_id"
        
    }
    
    struct Story {
        static let uid              = "uid"
        static let title            = "title"
        static let audioFormat      = "audio_format"
        static let recordingLength  = "recording_length"
        static let recordingURL     = "recording_url"
        static let date_recorded    = "date_recorded"
        
    }
    
    struct NotificationUserInfo {
        struct PhotoUpload {
            static let status = "status"
            static let progress = "progress"
            static let photoID = "photo_id"
            static let repoID = "repo_id"
            static let photoUploadInformation = "photo_upload_info"
        }
    }
}

struct Constants {
    
    static let AlphabetUppercase = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                                    "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
                                    "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                                    "w", "x", "y", "z"]
    static let Numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    static let Symbols = ["$", "#"]
    
    struct Fonts {
        struct MainFontFamilies {
            static let regular  = "Futura"
            static let bold     = "Futura-Medium"
            static let italics  = "Futura-MediumItalic"
        }
    }
    
    struct CellIdentifiers {
        
        static let ContentAddScreenChooseCell = "ContentAddScreenChooseCell"
        
        struct PhotoInfoVC {
            static let TFPhotoInfoRegularCellReuseID = "TFPhotoInfoRegularCellReuseID"
            
        }
    }
    
    
    
    struct SegueIDs {
        static let ToAddUser                            = "segueToAddUser"
        static let ToAddPhotograph                      = "segueToAddPhotograph"
        static let ToAddRecording                       = "segueToAddRecording"
        static let ToPhotoInformation                   = "showPhotoInformation"
        static let FromPhotoInfoToMainImageViewer       = "segueFromPhotoInfoToMainImageViewer"
        static let FromPhotoInfoToAddRecording          = "SegueFromPhotoInfoToAddRecording"
        static let SegueFromRepositoriesToTimelineView  = "segueFromRepositoriesViewToTimelineView"
        static let SegueFromTimelineToAddStoryScene     = "SegueFromTimelineToAddStoryScene"
        static let SegueFromTimelineToAddPhotograph     = "SegueFromTimelineToAddPhotograph"
        static let SegueFromHomeToSignInPage            = "segueFromHomeToSignInPage"
        static let SegueFromHomeToRegister              = "segueFromHomeToRegister"
        static let SegueFromHomeToRepositories          = "hometorepositoriessegue"
        //static let SegueFromTimelineViewToAddPhotograph = "seguefromtimelineviewtoaddphotograph"
        
    }
    
    struct Timeline {
        
        static let YearBoundIncrement       : Int = 5
        
        static let HorizontalInset          : CGFloat = 25.0
        static let VerticalInset            : CGFloat = 30.0
        static let MainLineWidth            : CGFloat = 1.0
        static let MainLineMargin           : CGFloat = 0.0
        static let MainTimelineHeight       : CGFloat = 2000.0
        
        
        struct IncrementLine {
            
            static let OriginalWidthModifer     : CGFloat = 0.4
            static let FiveYearWidthModifier    : CGFloat = 0.3
            static let RegularWidthModifier     : CGFloat = 0.2
            
        }
        
        
        struct PhotographCell {
            static let Height                   : CGFloat = 60.0
            static let Width                    : CGFloat = 60.0
            static let CornerRadius             : CGFloat = 4.0
            
            static let PlaceholderImageHeight   : CGFloat = 50.0
            static let PlaceholderImageWidth    : CGFloat = 50.0
        }
    }
    
    
    struct PhotoInformationVC {
        
        static let ImageHeaderHeight : CGFloat = 200.0
        
        
        struct TableViewCells {
            static let TFInfoCellRegularHeight : CGFloat = 100.0
            static let TFInfoCellTitleFontSize : CGFloat = 15.0
            static let TFInfoCellMainLabelFontSize : CGFloat = 13.0
            static let TFInfoCellSupplementaryLabelFontSize : CGFloat = 10.0
            static let TFInfoCellTitleLeftMargin : CGFloat = 10.0
            
            struct InfoCell {
                static let TitleLabelLeftMargin : CGFloat = 10.0
                static let MainLabelLeftMargin : CGFloat = 8.0
                static let CellHeight : CGFloat = 100.0
                static let ReuseIdentifier = "TFPhotoInfoRegularCellReuseID"
            }
            
            struct InfoDateCell {
                static let ReuseIdentifier = "InfoDateCellReuseIdentifier"
                static let CellHeight : CGFloat = 75.0
                static let TitleLabelLeftMargin : CGFloat = 10.0
                static let MainLabelLeftMargin : CGFloat = 20.0
                static let TitleLabelHeight : CGFloat = 20.0
            }
            
            struct InfoLocationCell {
                static let ReuseIdentifier = "InfoLocationCellReuseIdentifier"
                static let CellHeight : CGFloat = 400.0
                static let TitleLabelLeftMargin : CGFloat = 10.0
                static let MainLabelLeftMargin : CGFloat = 8.0
            }
        }
    }
    
    struct AudioPlayerControlBar {
        static let mainHeight : CGFloat = 100.0
        static let timeLabelWidth : CGFloat = 50.0
        static let timeLabelHorizontalOffset : CGFloat = 5.0
        static let titleLabelInset : CGFloat = 5.0
        static let progressViewHeight : CGFloat = 2.0
        static let buttonWidth : CGFloat = 50.0
        
    }
    
    struct FileManager {
        static let tempPath = "temp"
        static let tempRecordingPath = "temp/recordings"
    }
    
    
    struct DataManager {
        static let firebaseStorageURL = "gs://capstone2017-4504b.appspot.com"
        static let firebaseThumbnailImagesPath = "images/thumbnail"
        static let firebaseMainImagesPath = "images/main"
        static let firebaseRecordingsPath = "recordings"
    }
    
    
    struct Notifications {
        struct Upload {
            static let photoUploadProgressUpdate = "photouploadprogressupdate"
            static let photoUploadHasNewUpload = "photouploadhasnew"
            static let photoUploadDidRemoveUpload = "photouploadDidRemoveUpload"
        }
    }
}

typealias Font = UIFont

extension Font {
    
    static func PARegularFontWithSize( size : CGFloat ) -> Font {
        
        if let f =  Font(name: Constants.Fonts.MainFontFamilies.regular, size: size) {
            return f
        }
        else {
            return Font.systemFont(ofSize: size)
        }
    }
    
    static func PABoldFontWithSize( size : CGFloat ) -> Font {
        
        if let f = Font(name: Constants.Fonts.MainFontFamilies.bold, size: size) {
            return f
        }
        else {
            return Font.boldSystemFont(ofSize: size)
        }
    }
    
    static func PAItalicsFontWithSize( size : CGFloat ) -> Font {
    
        if let f = Font(name: Constants.Fonts.MainFontFamilies.italics, size: size) {
            return f
        }
        else {
            return Font.italicSystemFont(ofSize: size)
        }
    }
    
    
    
    
}

extension Color {
    
    static var MainApplicationColor : Color {
        get {
            return Color(red: 192.0.CGFloatRGBValue, green: 57.0.CGFloatRGBValue, blue: 43.0.CGFloatRGBValue, alpha: 1.0)
        }
    }
    
    
    static var TimelineBackgroundColor : Color {
        get {
            return Color(red: RGBVal(v: 33.0), green: RGBVal(v: 33.0), blue: RGBVal(v: 33.0), alpha: 1.0)
        }
    }
    
    static var TimelineLineColor : Color {
        get {
            return Color(white: 0.3, alpha: 1.0)
        }
    }
    
    static var TimelineIncrementLineColor : Color {
        get {
            return Color(white: 0.3, alpha: 0.7)
        }
    }
    
    static var TimelineEndpointColor : Color {
        get {
            return Color(white: 0.5, alpha: 1.0)
        }
    }
    
    static var PADarkBlue : Color {
        get {
            
            return Color(red: 59.0.CGFloatRGBValue, green: 88.0.CGFloatRGBValue, blue: 152.0.CGFloatRGBValue, alpha: 1.0.CGFloatValue)
        }
    }
    
    static var PAWhiteOne : Color {
        get {
            return Color(white: 1.0, alpha: 0.9)
        }
    }
    
    static var PAWhiteTwo : Color {
        get {
            return Color(white: 0.75, alpha: 1.0)
        }
    }
}

extension Double {
    
    func RGBValue() -> Double {
        return self / 255.0
    }
}
extension CGFloat {
    
    func constrainToBounds( lowerBound : CGFloat, upperBound : CGFloat ) -> CGFloat {
        if self > upperBound { return upperBound }
        if self < lowerBound { return lowerBound }
        return self
    }
    
    func PARGBValue() -> CGFloat {
        return self / 255.0
    }
}

extension CGPoint {
    
    func verticalDistanceToPoint( pnt : CGPoint) -> CGFloat {
        
        return abs( self.y - pnt.y )
    }
    
    func horizontalDistanceToPoint( pnt : CGPoint ) -> CGFloat {
        
        return abs( self.x - pnt.x )
    }
}

class PARandom {
    
    static func string( length : Int = 40) -> String {
        
        var startingString = ""
        
        
        for i in 0...length {
            
            //  First choose the array to grab a character from
            
            let randBool = PARandom.randomBool()
            var alphabet : [String]!
            
            if randBool {
                alphabet = Constants.AlphabetUppercase
            } else {
                alphabet = Constants.AlphabetUppercase
            }
            
            let arr_length = alphabet.count
            
            let randomIndex = PARandom.randomArrayIndexForLength(length: arr_length)
            
            let newChar = alphabet[randomIndex]
            
            startingString += newChar
        }
        
        return startingString
    }
    
    static func randomArrayIndexForLength( length : Int ) -> Int {
        
        return Int(arc4random_uniform(UInt32(length)))
    }
    
    static func randomBool() -> Bool {
        
        let upperBound = 5000
        
        let randomInt = arc4random_uniform(UInt32(upperBound))
        
        if randomInt % 2 == 0 { return true }
        
        return false
    }
    
    static func randomDoubleInSpan( start : Double, end : Double ) -> Double {
        
        let totalSpan = abs(end-start)
        
        let randDouble = Double(Float(arc4random()) / Float(UINT32_MAX))
        
        let randAddition = totalSpan * randDouble
        
        return start + randAddition
    }
    
    static func randomCGFloatInSpan( start : Double, end : Double ) -> CGFloat {
        
        let totalSpan = abs(end-start)
        
        let randDouble = Double(Float(arc4random()) / Float(UINT32_MAX))
        
        let randAddition = totalSpan * randDouble
        
        return CGFloat(start + randAddition)
    }
    static func randomCGFloatInSpan( start : CGFloat, end : CGFloat ) -> CGFloat {
        
        let totalSpan = abs(end-start)
        
        let randDouble = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        let randAddition = totalSpan * randDouble
        
        return (start + randAddition)
    }
    
    static func randomRGBValue() -> CGFloat {
        
        let start = 0.0
        let end = 255.0
        
        var rand : CGFloat = PARandom.randomCGFloatInSpan(start: start, end: end)
        
        rand = rand / 255.0
        
        return rand
    }
}

class PAInformationDictionary {
    
    private var values = [String : String]()
    
    private let na = "Not Available"
    
    func insert(stringValue val : String? , forKey k : String) {
        
        if let v = val {
            values[k] = v
        } else {
            values[k] = na
        }
    }
    
    func insert(floatValue val : Float?, forKey k : String ) {
        if let v = val {
            values[k] = String(v)
        } else {
            values[k] = na
        }
    }
    func insert(intValue val : Int?, forKey k : String ) {
        if let v = val {
            values[k] = String(v)
        } else {
            values[k] = na
        }
    }
    
    
    func insert(dateValue val : Date?, forKey k: String ) {
        if let v = val {
            values[k] = PADateManager.sharedInstance.getDateString(date: v, formatType: .Pretty)
        } else {
            values[k] = na
        }
    }
    
    func getStringDescriptor() -> String {
        
        return values.description
    }
}

