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
    func PADataManagerDidFinishUploadingStory( storyID : String )
    func PADataManagerDidUpdateProgress( progress : Double )
    func PADataManagerDidDeleteStoryFromPhotograph( story : PAStory, photograph : PAPhotograph )
    func PADataManagerDidDeletePhotograph( photograph : PAPhotograph )
}











class PADataManager {
    
    static let sharedInstance = PADataManager()
    
    let uploadsMan = PAUploadsManager()
    
    
    var database_ref            : FIRDatabaseReference?
    var storage_ref             : FIRStorageReference?
    var recordings_storage_ref  : FIRStorageReference?
    var delegate                : PADataManagerDelegate?
    
    
    var currentUserID : String {
        if let id = FIRAuth.auth()?.currentUser?.uid {
            return id
        }
        else {
            return ""
        }
    }
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
        
        self.configTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(PADataManager.configureFireFunction),
            userInfo: nil,
            repeats: true)
    
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
    
    func pullRepositoriesForUserID( userID : String ) {
        
        guard isConfigured else { return }
        
        let joined_repos_ref = database_ref!.child(String.init(format: "users/%@/%@", userID, Keys.User.joinedRepositories))
        
        joined_repos_ref.observe(.childAdded, with: { (snapshot) in
            
            let repo_key = snapshot.key
            
            self.database_ref!.child(String.init(format: "repositories/%@", repo_key)).observeSingleEvent(of: .value, with: { (repo_snapshot) in
                
                if let new_repo = PARepository.CreateWithFirebaseSnapshot(snap: repo_snapshot) {
                    self.delegate?.PADataManagerDidGetNewRepository(new_repo)
                }
            })
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
    
    func deletePhotograph( photo : PAPhotograph, repo : PARepository? ) {
        
        guard isConfigured else { return }

        
        guard let photo_uploaded_by = photo.uploaderID else {
            return
        }
        
        if photo_uploaded_by == "" {
            return
        }
        
        guard currentUserID == photo_uploaded_by else {
            
            let noteInfo : [String : Any] = [
                NotificationKeys.PhotoDelete.status : PhotoDeleteStatus.errorDeleting,
                NotificationKeys.PhotoDelete.photoID : photo.uid,
                NotificationKeys.PhotoDelete.error : "You don't have the proper permissions to delete this file"
            ]
            
            let note = Notification(name: Notifications.errorDeletingPhotograph.name, object: nil, userInfo: noteInfo)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(note)
            }
            
            return
        }
        
        let thumb_storage_path = String.init(format: "images/thumb_%@.jpg", photo.uid)
        let main_storage_path = String.init(format: "images/%@.jpg", photo.uid)
        let photo_db_path = String.init(format: "photographs/%@", photo.uid)
        
        
        let photo_db_ref = database_ref!.child(photo_db_path)
        
        photo_db_ref.removeValue()
        
        let main_storage_ref = storage_ref!.child(main_storage_path)
        
        main_storage_ref.delete(completion: { (error) in
            if error != nil {
                let error_message = String.init(format: "\nThere was an error deleting the image -> %@ error -> %@\n", photo.uid, error!.localizedDescription)
                
                print( error_message )
                return
            }
            
            let noteInfo : [String : Any] = [
                NotificationKeys.PhotoDelete.status : PhotoDeleteStatus.didDelete,
                NotificationKeys.PhotoDelete.photoID : photo.uid
            ]
            
            let note = Notification(name: Notifications.didDeletePhotograph.name, object: nil, userInfo: noteInfo)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(note)
            }
            
        })
        
        
        if photo.hasThumbnail {
            let thumb_storage_ref = storage_ref!.child(thumb_storage_path)
            thumb_storage_ref.delete(completion: { (error) in
                if let error = error {
                    let error_message = String.init(format: "\nThere was an error deleting the image -> %@ error -> %@\n", photo.uid, error.localizedDescription)
                    
                    print( error_message )
                    return
                }
                
                
                
                
            })
        }
        
        if let repo = repo {
            
            let repo_ref = database_ref!.child(String.init(format: "repositories/%@/photos/%@", repo.uid, photo.uid))
            
            repo_ref.removeValue()
            
            decrementRepositoryPhotoCount(repo_id: repo.uid)
        }
        
        
        self.delegate?.PADataManagerDidDeletePhotograph(photograph: photo)
        
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
        
        
        //  If the date on the photograph is not within the range of the repository
        //  then update either the 'end_date' or 'start_date' on the repository
        
        if
            let start_date = repository.startDate,
            let end_date = repository.endDate,
            let photo_date = newPhoto.dateTaken {
            
            let new_value = PADateManager.sharedInstance.getDateString(date: photo_date, formatType: .FirebaseFull)
            
            switch (photo_date.compareToPeriod(start_date: start_date, end_date: end_date)) {
                
            case .isBeforePeriod:
                repository_db_ref.child(Keys.Repository.startDate).setValue(new_value)
                
                
            case .isAfterPeriod:
                repository_db_ref.child(Keys.Repository.endDate).setValue(new_value)
                
            default:
                break;
            }
        }
        
        
        
        
        
        let current_user_id = FIRAuth.auth()?.currentUser?.uid
        
        newPhoto.uploaderID = current_user_id
        
        let new_photograph_key = photographs_db_ref.childByAutoId().key
        
        
        
        
        
        
        
        
        let began_uploading_notification = Notification.init(name: Notifications.beganUploadingPhotograph.name, object: nil, userInfo: [
            NotificationKeys.PhotoUploaded.status : PhotoUploadStatus.beganUploading,
            NotificationKeys.PhotoUploaded.photoID : new_photograph_key
            ])
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(began_uploading_notification)
        }
        
        
        
        
        
        
        
        
        
        let image_metadata = FIRStorageMetadata()
        image_metadata.contentType = "image/jpeg"
        image_metadata.customMetadata = [ "photo_id" : new_photograph_key ]
        
        
        let upload_task = storage_ref!.child(String.init(format: "images/%@.jpg", new_photograph_key)).put(image_data, metadata: image_metadata) { (metaData, error) in
            
            if let error = error {
                self.handleError(error: error)
                return
            }
            
            
            self.incrementRepositoryPhotoCount(repo_id: repository.uid)
            
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
            
            
            let didUploadNote = Notification.init(name: Notifications.didAddPhotograph.name, object: nil, userInfo: [ NotificationKeys.PhotoUploaded.status : PhotoUploadStatus.didUpload,
                                                                                                                      NotificationKeys.PhotoUploaded.photoID : new_photograph_key
                ])
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(didUploadNote)
            }
            
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
    fileprivate func decrementRepositoryPhotoCount( repo_id : String ) {
        
        guard isConfigured else { return }
        
        let number_ref = database_ref!.child("repositories").child(repo_id).child(Keys.Repository.totalPhotographs)
        
        number_ref.observeSingleEvent(of: .value, with: { (snapper) in
            
            if let val = snapper.value as? Int {
                
                number_ref.setValue(val.decrement())
            }
        })
    }
    fileprivate func incrementRepositoryPhotoCount( repo_id : String ) {
        
        guard isConfigured else { return }
        
        let number_ref = database_ref!.child("repositories").child(repo_id).child(Keys.Repository.totalPhotographs)
        
        number_ref.observeSingleEvent(of: .value, with: { (snapper) in
            
            if let val = snapper.value as? Int {
                
                number_ref.setValue(val.increment())
            }
        })
    }
    
    
    func updatePhotographValues( photo : PAPhotograph, repo : PARepository ) {
        
        guard isConfigured else { return }
        
        
        let repo_db_ref = database_ref!.child(String.init(format: "repositories/%@", repo.uid))
        
        
        if  let photo_date = photo.dateTaken,
            let repo_start = repo.startDate,
            let repo_end = repo.endDate
        {
            
            let new_value = PADateManager.sharedInstance.getDateString(date: photo_date, formatType: .FirebaseFull)
            
            
            switch photo_date.compareToPeriod(start_date: repo_start, end_date: repo_end) {
            case .isBeforePeriod:
                repo_db_ref.child(Keys.Repository.startDate).setValue(new_value)
                repo.startDate = photo_date
                
            case .isAfterPeriod:
                repo_db_ref.child(Keys.Repository.endDate).setValue(new_value)
                repo.endDate = photo_date
                
                
            default:
                
                break
            }
            
            
            
            
        }
        
        
        let photo_db_ref = database_ref!.child(String.init(format: "photographs/%@", photo.uid))
        
        photo_db_ref.child(Keys.Photograph.title).setValue(photo.title)
        
        photo_db_ref.child(Keys.Photograph.description).setValue(photo.longDescription)
        
        photo_db_ref.child(Keys.Photograph.dateTakenConf).setValue(photo.dateTakenConf)
        
        if let d = photo.dateTaken {
            let date_string = PADateManager.sharedInstance.getDateString(date: d, formatType: .FirebaseFull)
            
            photo_db_ref.child(Keys.Photograph.dateTaken).setValue(date_string)
        }
        
        if let coord = photo.locationTaken.coordinates {
            
            let lat = String.init(format: "%2.7f", coord.latitude)
            let long = String.init(format: "%2.7f", coord.longitude)
            
            photo_db_ref.child(Keys.Photograph.locationLatitude).setValue(coord.latitude)
            photo_db_ref.child(Keys.Photograph.locationLongitude).setValue(coord.longitude)
        }
        
        photo_db_ref.child(Keys.Photograph.locationConf).setValue(photo.locationTakenConf)
        
        if let state = photo.locationState {
            photo_db_ref.child(Keys.Photograph.locationState).setValue(state)
        }
        
        if let country = photo.locationCountry {
            photo_db_ref.child(Keys.Photograph.locationCountry).setValue(country)
        }
        
        if let zip = photo.locationZIP {
            photo_db_ref.child(Keys.Photograph.locationZIP).setValue(zip)
        }
        
        if let city = photo.locationCity {
            photo_db_ref.child(Keys.Photograph.locationCity).setValue(city)
        }
        
        photo_db_ref.child(String.init(format: "%@/%@", Keys.Photograph.iosData, Keys.Photograph.iOS.mapDegreesDelta)).setValue(photo.iosData.degreesDelta)
        
    }
    func uploadNewRepository( repository : PARepository ) {
        
        if !isConfigured { return }
        
        let db_ref = database_ref!.child("/repositories")
        let user_db_ref = database_ref!.child(String.init(format: "users/%@", PAGlobalUser.sharedInstace.userID))
        
        let new_key = db_ref.childByAutoId().ref.key
        
        repository.uid = new_key
        repository.dateCreated = Date()
        repository.creatorID = FIRAuth.auth()?.currentUser?.uid ?? ""
        
        let repository_json_information = repository.GetJSONCompatibleArray()
        
        db_ref.child(new_key).setValue(repository_json_information) { (error, database_reference) in
            
            if error != nil {
                
                let err_message = "\nThere was an error set the repository value\n"
                print( err_message )
                return
            }
            
            
        }
        
        
        user_db_ref.child(String.init(format: "%@/%@", Keys.User.myRepositories, new_key)).setValue("true")
        
        user_db_ref.child(String.init(format: "%@/%@", Keys.User.joinedRepositories, new_key)).setValue("true")
        
        
        
        
        
        let success_message = String.init(format: "\nSuccessfully uploaded repository with ID -> %@\n", new_key )
        
        print( success_message )
        
        let note = Notification(name: Notifications.didUploadNewRepository.name, object: nil, userInfo: nil)
        
        NotificationCenter.default.post(note)
    }
    
    func updateRepository( repo : PARepository ) {
        
        guard isConfigured else { return }
        
        
        let repo_ref = database_ref!.child(String.init(format: "repositories/%@", repo.uid))
        
        let date_man = PADateManager.sharedInstance
        
        if let start_date = repo.startDate {
            let start_date_str = date_man.getDateString(date: start_date, formatType: .FirebaseFull)
            
            repo_ref.child(Keys.Repository.startDate).setValue(start_date_str)
        }
        
        if let end_date = repo.endDate {
            let end_date_str = date_man.getDateString(date: end_date, formatType: .FirebaseFull)
            
            repo_ref.child(Keys.Repository.endDate).setValue(end_date_str)
        }
        
        repo_ref.child(Keys.Repository.title).setValue(repo.title)
        repo_ref.child(Keys.Repository.longDescription).setValue(repo.longDescription)
        
        
        let note = Notification(name: Notifications.didUpdateRepository.name)
        
        NotificationCenter.default.post(note)
    }
    
    func deleteRepository( repo : PARepository ) {
        
        guard isConfigured else { return }
        
        guard let userID = FIRAuth.auth()?.currentUser?.uid else { return }
        
        guard repo.creatorID == userID else {
            print( "You didn't create this repo".PAPadWithNewlines() )
            return
        }
        
        let repo_db_ref = database_ref!.child(String.init(format: "repositories/%@", repo.uid))
        
        repo_db_ref.removeValue()
        
        let user_db_ref = database_ref!.child(String.init(format: "users/%@", repo.uid))
        
        user_db_ref.child(Keys.User.myRepositories).child(repo.uid).removeValue()
        
        user_db_ref.child(Keys.User.joinedRepositories).child(repo.uid).removeValue()
        
        print(String.init(format: "Did delete repo with id -> %@", repo.uid).PAPadWithNewlines())
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
    
    func getNewStoryUID() -> String? {
        
        guard isConfigured else { return nil }
        
        let story_db_ref = database_ref!.child("stories")
        
        let new_child = story_db_ref.childByAutoId()
        
        new_child.setValue("placeholder")
        
        return new_child.key
    }
    
    func addNewStory( new_story : PAStory, photograph : PAPhotograph ) {
        
        guard isConfigured else { return }
        
        guard let curr_user_id = FIRAuth.auth()?.currentUser?.uid else {
            print("Can't upload story no user signed in...")
            return
        }
        
        let story_storage_ref = storage_ref!.child(String.init(format: "recordings/%@.mp4", new_story.uid))
        let story_db_ref = database_ref!.child(String.init(format: "stories/%@", new_story.uid))
        let photo_db_ref = database_ref!.child(String.init(format: "photographs/%@", photograph.uid))
        
        new_story.dateUploaded = Date()
        new_story.uploaderID = curr_user_id
        
        guard let local_url = new_story.tempRecordingURL else {
            print( "There was no URL for this story..." )
            return
        }
        
        let audio_upload_metadata = FIRStorageMetadata()
        audio_upload_metadata.contentType = "audio/mp4"
        
        let story_upload_task = story_storage_ref.putFile(local_url, metadata: audio_upload_metadata) { (metaDataCompletion, error) in
            
            if let error = error {
                let error_message = String.init(format: "\nThere was an error uploading the story audio -> %@ \n", error.localizedDescription)
                print( error_message )
                
                return
            }
            
            guard let download_url = metaDataCompletion?.downloadURL() else {
                print("There was no download URL for this story")
                return
            }
            
            new_story.recordingURL = download_url.absoluteString
            let new_story_data = new_story.getJSONCompatibleArray()
            
            story_db_ref.setValue(new_story_data)
            
            let stories_child_db_ref = photo_db_ref.child("stories")
            
            stories_child_db_ref.child(new_story.uid).setValue("true")
            
            self.delegate?.PADataManagerDidFinishUploadingStory(storyID: new_story.uid)
            
            let done_message = String.init(format: "\nFinished uploading everything, photo_id -> %@, story_id -> %@\n", photograph.uid, new_story.uid)
            print( done_message )
        }
        
        
        story_upload_task.observe(.progress) { (snap) in
            
            if let progress = snap.progress?.fractionCompleted {
                let progress_message = String.init(format: "\nTotal Progress:\t%0.2f\n", progress)
                
                print( progress_message )
                
                self.delegate?.PADataManagerDidUpdateProgress(progress: progress)
            }
        }
        
    }
    
    func deleteStoryForPhotograph( story : PAStory, photograph : PAPhotograph ) {
        
        guard isConfigured else { return }
        
        guard let uploader_id = story.uploaderID else { return }
        guard let current_user_id = FIRAuth.auth()?.currentUser?.uid else { return }
        
        guard uploader_id == current_user_id else { return }
        
        
        let bucket_path = String.init(format: "recordings/%@.mp4", story.uid)
        
        let storage_ref = self.storage_ref!.child(bucket_path)
        let story_db_ref = self.database_ref!.child("stories").child(story.uid)
        let photograph_story_ref = self.database_ref!.child("photographs").child(photograph.uid).child("stories").child(story.uid)
        
        storage_ref.delete { (error) in
            if let error = error {
                print("Error deleting file")
                return
            }
        }
        
        story_db_ref.removeValue()
        photograph_story_ref.removeValue()
        
        self.delegate?.PADataManagerDidDeleteStoryFromPhotograph(story: story, photograph: photograph)
        
    }
}

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
