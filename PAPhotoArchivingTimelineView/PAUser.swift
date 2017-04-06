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
    
    lazy var timerFireLimit : Int = {
       
        let fireInterval = 0.01
        let minuteTimeLimit = 3
        let totalSecondsLimit = minuteTimeLimit * 60
        
        let fireIntervalCounter = Int(Double(totalSecondsLimit) / fireInterval)
        
        return fireIntervalCounter
    }()
    
    var currentCounter = 0
    
    private var _configTimer : Timer?
    
    private var _user : PAUser? {
        didSet {
            didSetupuser()
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
        
    }
    
}
