//
//  PADataManager.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/8/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import Firebase
import UIKit


enum PAUploadStatus {
    case Paused, InProgress, Completed, Unknown
}


extension Notification {
    
    static func PABuildPhotoUploadNotification( status : PAUploadStatus, progress : Float, repo_id : String, photo_id : String) -> Notification {
        
        
        let user_info : [ String : Any ] = [
            Keys.NotificationUserInfo.PhotoUpload.photoID : photo_id,
            Keys.NotificationUserInfo.PhotoUpload.repoID : repo_id,
            Keys.NotificationUserInfo.PhotoUpload.status : status,
            Keys.NotificationUserInfo.PhotoUpload.progress : progress
        ]
        
        let notification = Notification(    name: Notification.Name(rawValue: Constants.Notifications.Upload.photoUploadProgressUpdate),
                                            object: nil,
                                            userInfo: user_info)
        
        return notification
    }
    
    static func PABuildPhotoUploadDidCompleteNotification( uploadInformation : PAPhotoUploadInformation ) -> Notification {
        
        let user_info : [ String : Any ] = [ Keys.NotificationUserInfo.PhotoUpload.photoUploadInformation : uploadInformation ]
        
        let notification = Notification(name: Notification.Name(rawValue: Constants.Notifications.Upload.photoUploadDidRemoveUpload), object: nil, userInfo: user_info)
        
        return notification
    }
    
    static func PABuildPhotoUploadWasAddedNotification( uploadInformation : PAPhotoUploadInformation ) -> Notification
    {
        let user_info : [ String : Any ] = [ Keys.NotificationUserInfo.PhotoUpload.photoUploadInformation : uploadInformation ]
        
        let notification = Notification(name: Notification.Name(rawValue: Constants.Notifications.Upload.photoUploadHasNewUpload), object: nil, userInfo: user_info)
        
        return notification
    }
}
fileprivate enum PAImageURLToDataError : Error {
    case invalidURL
    case dataCreationError( creationError : Error )
    
    var paDescription : String {
        get {
            switch self {
            case .invalidURL:
                return "The URL was invalid"
                
            case .dataCreationError(creationError: _):
                return "There was an error creating the data"
                
            default:
                return "Unknown description"
            }
        }
    }
}
enum PAUserSignInStatus {
    case SignInSuccess, SignInFailed, FirebaseNotConfigured
}

protocol PADataManagerDelegate {
    func PADataManagerDidGetNewRepository(_ newRepository : PARepository)
    func PADataMangerDidConfigure()
    func PADataManagerDidSignInUserWithStatus(_ signInStatus : PAUserSignInStatus)
}

class PADataManager {
    
    static let sharedInstance = PADataManager()
    
    let uploadsMan = PAUploadsManager()
    
    
    var database_ref            : FIRDatabaseReference?
    var storage_ref             : FIRStorageReference?
    var recordings_storage_ref  : FIRStorageReference?
    var delegate                : PADataManagerDelegate?
    
    
    var configTimer : Timer?
    
    var isConfigured = false
    
    var isSignedIn : Bool {
        get {
            if FIRAuth.auth()?.currentUser != nil {
                return true
            }
            
            return false
        }
    }
    
    init()
    {
        
    }
    
    func configure() {
        
        guard !self.isConfigured else {
            TFLogger.log(logString: "The data manger is already configured...")
            return
        }
        
        self.configTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PADataManager.configureFireFunction), userInfo: nil, repeats: true)
    }
    
    @objc func configureFireFunction() {
        
        if self.isConfigured {
            if let time = self.configTimer {
                time.invalidate()
                self.configTimer = nil
            }
            
            return
        }
        
        //  If Firebase is already configured then stop the timer and do personal configuration
        
        if (FIRApp.defaultApp() != nil) {
            database_ref            = FIRDatabase.database().reference()
            storage_ref             = FIRStorage.storage().reference(forURL: Constants.DataManager.firebaseStorageURL)
            recordings_storage_ref  = storage_ref?.child(Constants.DataManager.firebaseRecordingsPath)
            
            self.isConfigured = true
            
            self.delegate?.PADataMangerDidConfigure()
        }
        
    }
    
    
    func signInUserWithCredentials( username : String , password : String ) {
        
        guard isConfigured else {
            self.delegate?.PADataManagerDidSignInUserWithStatus(.FirebaseNotConfigured)
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: { (user, error) in
            
            //  First check to see if there was an error
            if error != nil {
                self.delegate?.PADataManagerDidSignInUserWithStatus(PAUserSignInStatus.SignInFailed)
                return
            }
            
            //  Let the delegate know that the sign in was successful
            self.delegate?.PADataManagerDidSignInUserWithStatus(PAUserSignInStatus.SignInSuccess)
        })
        
    }
    func addStoryToPhotograph( story : PAStory, photograph : PAPhotograph) {
        
        //  First upload the file
        guard isConfigured else {
            self.delegate?.PADataManagerDidSignInUserWithStatus(.FirebaseNotConfigured)
            return
        }
        
        if let data_url = story.tempRecordingURL, let rec_ref = self.recordings_storage_ref, let db_ref = database_ref {
            
            let child_ref = rec_ref.child("\(story.uid).m4a")
            
            let _ = child_ref.putFile(data_url, metadata: nil, completion: { (storage_metadata, err) in
                
                if let err = err {
                    TFLogger.log(str: "There was an error uploading the file", err: err)
                    return
                }
                
                TFLogger.log(logString: "Uploaded the file with metadata %@", arguments: (storage_metadata?.description)!)
                
                if let storage_metadata = storage_metadata {
                    if let download_url = storage_metadata.downloadURL() {
                        story.recordingURL = download_url.absoluteString
                        let photo_ref = db_ref.child("photographs/\(photograph.uid)")

                        let stories_ref = photo_ref.child("stories")
                        let new_story_ref = stories_ref.child(story.uid)
                        
                        new_story_ref.setValue(story.getFirebaseFriendlyArray())
                    }
                }
                //  Now create the database entry
                
                
            })
        }
    }
    
    
    func pullRepositories() {
        
        guard let dbRef = self.database_ref else {
            TFLogger.log(logString: "I couldn't get the database reference")
            return
        }
        
        
        let _ = dbRef.child("repositories").observe(.childAdded, with: { (snapshot) -> Void in
            
            if let newRepo = PARepository.CreateWithFirebaseSnapshot(snap: snapshot) {
                self.delegate?.PADataManagerDidGetNewRepository(newRepo)
            } else {
                let repositoryInformation = snapshot.debugDescription
                
                TFLogger.log(logString: "I couldn't create the repository with the following information %@", arguments: repositoryInformation)
            }
        })
    }
}


extension PADataManager {

    func handleError( error : Error ) {
        
        let error_message = String.init(format: "\nThere was an error...\nError Message:\t%@\n\n", error.localizedDescription )
        
        print( error_message )
    }
    
    fileprivate func handlePAError( error : PAImageURLToDataError ) {
        
        let error_message = String.init(format: "\nThere was an error...\nError Message:\t%@\n\n", error.paDescription )
        
        print( error_message )
    }
    
    func addPhotographToRepositoryv2( newPhoto : PAPhotograph, repository : PARepository ) {
        
        if !isConfigured { return }
        
        
        guard let main_image = newPhoto.mainImage else {
            print("No main image")
            return
        }
        
        guard let image_data = UIImageJPEGRepresentation(main_image, 1.0) else {
            print( "Could not convert to data")
            return
        }
        
        let photographs_db_ref  = database_ref!.child("/photographs")
        let repository_db_ref   = database_ref!.child(String.init(format: "/repositories/%@", repository.uid))
        
        
        let new_photograph_key = photographs_db_ref.childByAutoId().key
        
        let image_metadata = FIRStorageMetadata()
        image_metadata.contentType = "images/jpeg"
        
        let upload_task = storage_ref!.child(String.init(format: "images/%@.jpg", new_photograph_key)).put(image_data, metadata: image_metadata) { (metaData, error) in
            
            if let error = error {
                self.handleError(error: error)
                return
            }
            
            
            if let image_url = metaData?.downloadURLs?.first?.absoluteString {
                
                newPhoto.dateUploaded   = Date()
                newPhoto.mainImageURL   = image_url
                newPhoto.uid            = new_photograph_key
                photographs_db_ref.child(new_photograph_key).setValue(newPhoto.PAGetJSONCompatibleArray())
            }
            
            repository_db_ref.child(String.init(format: "photos/%@", new_photograph_key)).setValue("true")
            
            let note = Notification.PABuildPhotoUploadNotification(
                status: PAUploadStatus.Completed,
                progress: 1.0,
                repo_id: repository.uid,
                photo_id: new_photograph_key)
            
            NotificationCenter.default.post(note)
        }
        
        upload_task.observe(.progress) { (snap) in
            
            if let upload_progress = snap.progress {
                
                let upload_message = String.init(format: "\nUpload Progress:\t%.2f", upload_progress.fractionCompleted)
                
                print( upload_message )
                
                
                //  Post notification about upload progress
                let note = Notification.PABuildPhotoUploadNotification(status: PAUploadStatus.InProgress, progress: Float(upload_progress.fractionCompleted), repo_id: repository.uid, photo_id: new_photograph_key)
                
                NotificationCenter.default.post(note)
                
            }
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    func addPhotographToRepository( newPhoto : PAPhotograph, repository : PARepository ) {
        
        if !isConfigured { return }
        
        guard let mainImage = newPhoto.mainImage, let thumbImage = newPhoto.thumbnailImage else
        {
            TFLogger.log(logString: "Either the main image or thumb image was null, aborting")
            return
        }
        
        guard   let mainImageData = UIImageJPEGRepresentation(mainImage, 1.0),
                let thumbImageData = UIImageJPEGRepresentation(thumbImage, 1.0) else {
                
                TFLogger.log(logString: "Either the main image or the thumb image could not be converted into an NSData object")
                    
                return
        }
        
        guard let s_ref = self.storage_ref, let db_ref = self.database_ref else { return }
        
        let mainImageName = newPhoto.uid + ".jpg"
        let thumbImageName = newPhoto.uid + "_tn.jpg"
        
        let mainImagesPath = "images/main/"
        let thumbImagesPath = "images/thumbnail/"
        
        
        
        
        //let queue = DispatchQueue(label: "myDispatchQueue")
        let uploadGroup = DispatchGroup()
        
        
        var someError : Error?
        var thumbnailURL : String?
        var mainURL : String?
        
        
        let mData = FIRStorageMetadata()
        mData.contentType = "image/jpeg"
        
        uploadGroup.enter()
        let mainImageRef = s_ref.child(mainImagesPath + mainImageName)
        mainImageRef.put(mainImageData, metadata: mData, completion: { (metadata, error) in
            
            if error != nil {
                //  Abort
                someError = error!
                
            }
            
            if let dURL = metadata?.downloadURL() {
                mainURL = dURL.absoluteString
            }
            uploadGroup.leave()
        })
        
        let thumbImageRef = s_ref.child(thumbImagesPath + thumbImageName)
        uploadGroup.enter()
        thumbImageRef.put(thumbImageData, metadata: mData, completion: { (metadata, error) in
            
            if error != nil {
                someError = error
            }
            
            if let dURL = metadata?.downloadURL() {
                thumbnailURL = dURL.absoluteString
            }
            
            uploadGroup.leave()
        })
    
        
        
        uploadGroup.wait()
        
        
        if someError != nil {
            return
        }
        if mainURL != nil, thumbnailURL != nil {
            newPhoto.mainImageURL = mainURL!
            newPhoto.thumbnailURL = thumbnailURL!
        }
        else {
            TFLogger.log(logString: "One of the urls turned out to be nil")
            
        }
        
        
        //  Add the photograph
        uploadGroup.enter()
    
        let photographData = newPhoto.PAGetJSONCompatibleArray()
        let photosPath = "photographs/" + newPhoto.uid
        
        let photoRef = db_ref.child(photosPath)
        
        photoRef.setValue(photographData, withCompletionBlock: { (err, ref) in
            if let err = err {
                someError = err
            }
            
            uploadGroup.leave()
        })
        
        
        uploadGroup.wait()
        
        uploadGroup.enter()
        let pathToRepoPhotos = "repositories/" + repository.uid + "/photos"
        
        let photosDBRef = db_ref.child(pathToRepoPhotos).child(newPhoto.uid)
        
        photosDBRef.setValue("true", withCompletionBlock: { (err, ref) in
            
            if let err = err {
                someError = err
            }
            
            uploadGroup.leave()
        })
        
        uploadGroup.notify(queue: DispatchQueue.main) {
            print("Done ish")
        }
        
    }
}
//
//enum PASortType {
//    case ascending, descending
//}
//protocol PASortable {
//    var uintValue : UInt { get }
//}
//
//class PASortedDictionary {
//    lazy var values = [ String : Any ]()
//    var sortKey : String!
//    var sortType : PASortType = .ascending
//    
//    lazy var sortedIDs = [ String ]()
//    
//    var count : Int {
//        get {
//            return sortedIDs.count
//        }
//    }
//    
//    init(sort_key : String, sort_type : PASortType) {
//        
//        self.sortKey = sort_key
//        self.sortType = sort_type
//    }
//    
//    func addValueForKey( val : Any, key : String ) {
//        
//        values[key] = val
//        sortedIDs.append(key)
//    }
//    
//    func sortKeys() {
//        
//        
//    }
//    
//}
struct PAPhotoUploadInformation {
    var status : PAUploadStatus!
    var repositoryID : String!
    var photographID : String!
    var progress : Float = 0.0
    var uploadBeganTime : Date!
    var lastUpdateDate : Date!
}

class PAUploadsManager : NSObject {
    
    lazy var currentPhotoUploads = [String : PAPhotoUploadInformation]()
    lazy var sortedPhotoIDs = [ String ]()
    
    
    var currentUploads : Int {
        get {
            return self.currentPhotoUploads.count
        }
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PAUploadsManager.didReceivePhotoUploadNotification(sender:)), name: Notification.Name(rawValue : Constants.Notifications.Upload.photoUploadProgressUpdate), object: nil)
    }
    
    @objc func didReceivePhotoUploadNotification( sender : Notification ) {
        
        guard let user_info = sender.userInfo else {
            print( "No user info" )
            return
        }
        
        guard   let status      = user_info[Keys.NotificationUserInfo.PhotoUpload.status]   as? PAUploadStatus,
                let progress    = user_info[Keys.NotificationUserInfo.PhotoUpload.progress] as? Float,
                let photo_id    = user_info[Keys.NotificationUserInfo.PhotoUpload.photoID]  as? String,
                let repo_id     = user_info[Keys.NotificationUserInfo.PhotoUpload.repoID]   as? String else
        {
            print( "Not all the properties were set on that notification" )
            return
        }
        
        if self.currentPhotoUploads[photo_id] != nil {
            
            var record : PAPhotoUploadInformation! = self.currentPhotoUploads[photo_id]
            
            record.progress         = progress
            record.status           = status
            record.lastUpdateDate   = Date()
        }
        else {
            
            var new_record = PAPhotoUploadInformation()
            new_record.photographID = photo_id
            new_record.status = status
            new_record.repositoryID = repo_id
            new_record.progress = progress
            new_record.uploadBeganTime = Date()
            new_record.lastUpdateDate = Date()
            
            self.addPhotoInformation(photoInformation: new_record)
            
            NotificationCenter.default.post(Notification.PABuildPhotoUploadWasAddedNotification(uploadInformation: new_record))
        }
        
        if status == .Completed {
            
            if let uploadInformation = self.removePhotoInformation(photo_id: photo_id) {
                NotificationCenter.default.post(Notification.PABuildPhotoUploadDidCompleteNotification(uploadInformation: uploadInformation))
            }
        }
    }
    
    func addPhotoInformation( photoInformation : PAPhotoUploadInformation ) {
        
        self.currentPhotoUploads[photoInformation.photographID] = photoInformation
        self.sortedPhotoIDs.append(photoInformation.photographID)
    }
    
    func removePhotoInformation( photo_id : String ) -> PAPhotoUploadInformation? {
        
        
        
        if let i = self.sortedPhotoIDs.index(of: photo_id ) {
            self.sortedPhotoIDs.remove(at: i)
            
            return self.currentPhotoUploads.removeValue(forKey: photo_id)
        }
        
        return nil
        
    }
    
    func getInformationForIndexPath( i : Int ) -> PAPhotoUploadInformation? {
        
        return self.currentPhotoUploads[self.sortedPhotoIDs[i]]
    }
}
