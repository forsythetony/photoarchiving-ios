//
//  PAUser.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/6/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class PAGlobalUser {
    
    static let sharedInstace = PAGlobalUser()
    
    private var _profileImage : UIImage?
    private var _userEmail : String?
    private var _userID : String?
    private var _profileImageString : String?
    private var _isConfigured = false
    
    private var _joinedRepositories = [String]()
    private var _createdRepositories = [String]()
    
    lazy var timerFireLimit : Int = {
       
        let fireInterval = 0.01
        let minuteTimeLimit = 3
        let totalSecondsLimit = minuteTimeLimit * 60
        
        let fireIntervalCounter = Int(Double(totalSecondsLimit) / fireInterval)
        
        return fireIntervalCounter
    }()
    
    var currentCounter = 0
    
    private var _configTimer : Timer?
    
    fileprivate var _user : PAUser? {
        didSet {
            didSetupuser()
        }
    }
    
    var user : PAUser {
        get {
            return _user ?? PAUser()
        }
    }
    var userID : String {
        get {
            if let uid = _userID {
                return uid
            }
            
            return ""
        }
        
    }
    
    var joinedRepositories : [String] {
        get {
            return _joinedRepositories
        }
    }
    var userEmail : String {
        get {
            if let e = _user?.email {
                return e
            }
            
            return "No Email"
        }
    }
    
    var profileImage : UIImage {
        get {
            if let img = _profileImage {
                return img
            }
            
            return #imageLiteral(resourceName: "user_icon_white")
        }
    }
    
    init() {
        _setup()
    }
    
    func _setup() {
        
        if FIRAuth.auth()?.currentUser == nil {
            _setupTimer()
        }
        else {
            _isConfigured = true
            setupWithUserID(uid: FIRAuth.auth()!.currentUser!.uid)
        }
    }
    func _setupTimer() {
        
        _configTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(PAGlobalUser.timerFire), userInfo: nil, repeats: true)
        
        _configTimer?.fire()
    }
    
    @objc func timerFire() {
        
        guard self.currentCounter < self.timerFireLimit else {
            _configTimer?.invalidate()
            return
        }
        
        if FIRAuth.auth()?.currentUser != nil {
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                _configTimer?.invalidate()
                self.setupWithUserID(uid: uid)
                _isConfigured = false
                gatherJoinedRepositories()
                gatherCreatedRepositories() 
                return
            }
        }
    }
    
    func setupWithUserID( uid : String ) {
        
        let db_ref = FIRDatabase.database().reference(withPath: String.init(format: "users/%@", uid))
        
        _userID = uid
        
        
        db_ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self._user = PAUser.UserWithSnapshot(snap: snapshot)
        })
    }
    
    private func didSetupuser() {
        
        guard let user = _user else {
            return
        }
        
        guard user.profileImageURL != "" else {
            return
        }
        
        if let img_url = URL(string: user.profileImageURL) {

            ImageDownloader.default.downloadImage(with: img_url, options: nil, progressBlock: nil, completionHandler: { (img, error, url, data) in
                
                if let error = error {
                    
                    let error_string = String.init(format: "Error downloading image -> %@", error.localizedDescription)
                    
                    print( error_string.PAPadWithNewlines() )
                    
                    return
                }
                
                self._profileImage = img
                
                let note = Notification(name: Notifications.didDownloadProfileImage.name)
                
                NotificationCenter.default.post(note)
            })
            
            
        }
        
        monitorChanges()
        
    }
    
    private func monitorChanges() {
        
        let db_path = FIRDatabase.database().reference().child(String.init(format: "users/%@/", self.userID))
        
        db_path.child(Keys.User.photosUploaded).observe(.value, with: { (snapshot) in
            
            if let v = snapshot.value as? Int {
                self._user?.photosUploaded = v
            }
        })
        
        
        db_path.child(Keys.User.storiesUploaded).observe(.value, with: { (snapshot) in
            
            if let v = snapshot.value as? Int {
                self._user?.storiesUploaded = v
            }
        })
        
        db_path.child(Keys.User.repositoriesCreated).observe(.value, with: { (snapshot) in
            
            if let v = snapshot.value as? Int {
                self._user?.repositoriesCreated = v
            }
        })
        
        db_path.child(Keys.User.repositoriesJoined).observe(.value, with: { (snapshot) in
            
            if let v = snapshot.value as? Int {
                self._user?.totalRepositoriesJoined = v
            }
            
        })
    }
    
    func gatherJoinedRepositories() {
        
        PADataManager.sharedInstance.beginObservingJoinedRepositoriesForUser(user_id: userID) { (newRepoID) in
            self._joinedRepositories.append(newRepoID)
        }
    }
    
    func gatherCreatedRepositories() {
        PADataManager.sharedInstance.beginObservingCreatedRepositoriesForUser(user_id: userID) { (createdRepoID) in
            
            self._createdRepositories.append(createdRepoID)
        }
    }
    func doesUserHaveJoinedRepository( repo_id : String ) -> Bool {
        
        return _joinedRepositories.contains(repo_id)
    }
    
    func doesUserHaveCreatedRepository( repo_id : String ) -> Bool {
        
        return _createdRepositories.contains(repo_id)
    }
}

extension PAUser {
    var dateJoinedString : String {
        get {
            if let d = dateJoined {
                return PADateManager.sharedInstance.getDateString(date: d, formatType: .Pretty2)
            }
            else {
                return "Unavailable"
            }
        }
    }
    
    
}
