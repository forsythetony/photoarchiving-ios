
//
//  PATimelineViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/19/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import Firebase
import GoogleCast
import SCLAlertView
import Toast_Swift

fileprivate struct Action {
    
    static let addButton = #selector(PATimelineViewController.didTapAddButton(sender:))
}

class PATimelineViewController: UIViewController, PAChromeCasterDelegate {
    
    fileprivate var current_photo_to_delete : PAPhotograph?
    
    var ref : FIRDatabaseReference!
    var repositories : [FIRDataSnapshot]! = []
    var storageRef: FIRStorageReference!
    let chromecaster = PAChromecaster.sharedInstance
    
    var timelineView : PATimelineView?
    
    var isConnectedToChromecast = false
    
    var currentRepository : PARepository? {
        didSet {
            self.setupTimelineView()
        }
    }
    
    fileprivate var selected_date_for_new_photo : Date?
    
    fileprivate var _refHandle: FIRDatabaseHandle!
    
    var can_use : Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _removeListeners()
    }
    private func _removeListeners() {
        
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.removeObserver(self, name: Notifications.didAddPhotograph.name, object: nil)
        defaultCenter.removeObserver(self, name: Notifications.beganUploadingPhotograph.name, object: nil)
        defaultCenter.removeObserver(self, name: Notifications.didDeletePhotograph.name, object: nil)
        defaultCenter.removeObserver(self, name: Notifications.errorDeletingPhotograph.name, object: nil)
    }
    private func _setupListeners() {
        
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(PATimelineViewController.didReceivePhotoUploadNotification(sender:)), name: Notifications.didAddPhotograph.name, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(PATimelineViewController.didReceivePhotoBeganUploadingNotification(sender:)), name: Notifications.beganUploadingPhotograph.name, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(PATimelineViewController.didReceiveDidDeletePhotographNotifcation(sender:)), name: Notifications.didDeletePhotograph.name, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(PATimelineViewController.didReceiveErrorWhenDeletingPhotographNotification(sender:)), name: Notifications.errorDeletingPhotograph.name, object: nil)
        
    }
    func _setupCast() {
        
        GCKCastContext.sharedInstance().sessionManager.add(self)
        
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let button = GCKUICastButton.init(frame: frame)
        button.tintColor = Color.white
        
        let item = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = item
        
        
        
    }
    func showAlertViewWithDevice( device : GCKDevice ) {
        
        let a = UIAlertController(title: "Device Found", message: "Would you like to connect", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "Take no action", style: .cancel, handler: { action in

        })
        
        let connectAction = UIAlertAction(title: "Connect", style: .default, handler: { action in
            
            self.chromecaster.connectToDevice(dev: device)
        })
        
        a.addAction(noAction)
        a.addAction(connectAction)
        
        self.present(a, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //  Don't look for chromecasts at the moment
        //chromecaster.beginSearching()

        _setupListeners()
        self.navigationController?.navigationItem.PAClearBackButtonTitle()
    }
    
    func setupTimelineView() {
        var viewRect = self.view.bounds
        viewRect.origin.x = 0.0
        viewRect.origin.y = 0.0
        
        
        let rInfo = self.currentRepository ?? PARepository.Mock1()
        
        timelineView = PATimelineView(frame: viewRect, repoInfo: rInfo)
        timelineView?.delegate = self
        
        
        self.title = rInfo.title
        
        self.view.addSubview(timelineView!)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueID = segue.identifier {
            switch segueID {
            case Constants.SegueIDs.ToPhotoInformation:
                if let photoInfo = sender as? PAPhotograph {
                    
                    let dest = segue.destination as! TAPhotoInformationViewController
                    
                    dest.photoInfo = photoInfo
                }
                
                
            default:
                print("Default")
            }
        }
    }
    
    func didConnectToDevice(device: GCKDevice) {
        
    }
    
    func didFindNewDevice(device: GCKDevice) {
        self.showAlertViewWithDevice(device: device)
    }
    
    /*
        SETUP FUNCTIONS
    */
    private func _setup() {
        //_setupAddButton()
        _setupCast()
        _setupChromecast()
    }
    
    private func _setupAddButton() {
        
        let add_button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Action.addButton)
        
        self.navigationItem.rightBarButtonItem = add_button

        
//        self.navigationController?.navigationBar.barStyle = .black
//        self.navigationController?.navigationBar.tintColor = Color.white
        
    }
    
    private func _setupChromecast() {
        
        self.chromecaster.delegate = self
    }
}

/*
    ACTION HANDLERS
*/
extension PATimelineViewController : PADataManagerDelegate {
    func PADataManagerDidDeleteStoryFromPhotograph(story: PAStory, photograph: PAPhotograph) {
        
    }
    
    func PADataMangerDidConfigure() {
        
    }
    
    func PADataManagerDidUpdateProgress(progress: Double) {
        
    }
    func PADataManagerDidFinishUploadingStory(storyID: String) {
        
    }
    
    func PADataManagerDidGetNewRepository(_ newRepository: PARepository) {
        
    }
    
    func PADataManagerDidSignInUserWithStatus(_ signInStatus: PAUserSignInStatus) {
        
    }
    
    
    func PADataManagerDidDeletePhotograph(photograph: PAPhotograph) {
        
        self.currentRepository?.removePhotograph(photo: photograph)
        self.timelineView?.deletePhotograph(photo_info: photograph)
        
        self.current_photo_to_delete = nil
    }
}
extension PATimelineViewController : PATimelineViewDelegate {
    
    /*
        PHOTOGRAPHS
    */
    func PATimelineViewPhotographWasTapped(info: PAPhotograph) {
        
        TFLogger.log(logString: "Tapping image with information", arguments: info.getPhotoInfoData().description)
        
        let photo_info_vc = UIStoryboard.PAMainStoryboard.instantiateViewController(withIdentifier: PAPhotoInformationViewControllerv2.STORYBOARD_ID) as! PAPhotoInformationViewControllerv2
        
        photo_info_vc.currentRepository = self.currentRepository
        photo_info_vc.currentPhotograph = info
        
        if isConnectedToChromecast {
            self.sendItemToChromecast(photo: info)
        }
        self.present(photo_info_vc, animated: true, completion: nil)
        
    }
    
    func PATimelineViewPhotographWasLongPressed(info: PAPhotograph) {
        
        if current_photo_to_delete == nil {
            current_photo_to_delete = info
        }
        else {
            return
        }
        
        let alertView = SCLAlertView()
        
        alertView.addButton("Yes") {
            PADataManager.sharedInstance.delegate = self
            PADataManager.sharedInstance.deletePhotograph(photo: info, repo: self.currentRepository)
        }
        
        alertView.showWarning("Careful there", subTitle: "Are you sure you want to delete this photograph?")
    }
    func PATimelineViewLongPress(date: Date?) {
        
        if let pressDate = date {
            self.selected_date_for_new_photo = pressDate
        }
        
        didTapAddButton(sender: nil)
    }
    
    
    /*
        BUTTONS
    */
    func didTapAddButton( sender : UIBarButtonItem? ) {
        
        let message = "\nLooks like you tapped the add button there kiddo!\n"
        
        print(message)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let add_photograph_vc = storyboard.instantiateViewController(withIdentifier: PAAddPhotoViewController.STORYBOARD_ID) as! PAAddPhotoViewController
        
        if let date_pressed = self.selected_date_for_new_photo {
            add_photograph_vc.start_date = date_pressed
        }
        
        add_photograph_vc.currentRepository = self.currentRepository
        
        self.present(add_photograph_vc, animated: true, completion: nil)
    }
    
    
    func sendItemToChromecast( photo : PAPhotograph ) {
        
        let hasConnectedSession : Bool = GCKCastContext.sharedInstance().sessionManager.hasConnectedSession()
        
        if hasConnectedSession {
            
            let metadata = GCKMediaMetadata.init()
            metadata.setString(photo.title, forKey: kGCKMetadataKeyTitle)
            metadata.setString(PADateManager.sharedInstance.getDateString(date: photo.dateTaken ?? Date(), formatType: .Pretty), forKey: kGCKMetadataKeySubtitle)
            
            let mediaInfo = GCKMediaInformation.init(contentID: photo.mainImageURL, streamType: GCKMediaStreamType.buffered, contentType: "image/jpeg", metadata: metadata, streamDuration: TimeInterval.infinity, customData: nil)
            
            GCKCastContext.sharedInstance().sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInfo)
        }
    }
}

extension PATimelineViewController : GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        
        isConnectedToChromecast = true
        print("I started a session!")
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
        
        isConnectedToChromecast = true
        print("I resumed!")
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        isConnectedToChromecast = false
    }
    
}

extension PATimelineViewController {
    
    func didReceivePhotoUploadNotification( sender : Notification ) {
        
        guard let senderData = sender.userInfo else {
            return
        }
        
        guard let status = senderData[NotificationKeys.PhotoUploaded.status] as? PhotoUploadStatus else {
            return
        }
        
        if status == .didUpload {
            self.displaySuccessToast(message: "Uploaded photograph!", duration: 2.0, toastSuperview: self.timelineView ?? self.view)
        }
        else {
            self.displayErrorToast(message: "Couldn't upload photo", duration: 2.0, toastSuperview: self.timelineView ?? self.view)
        }
    }
    
    
    func didReceivePhotoBeganUploadingNotification( sender : Notification ) {
        
        guard let senderData = sender.userInfo else {
            return
        }
        
        guard let status = senderData[NotificationKeys.PhotoUploaded.status] as? PhotoUploadStatus else {
            return
        }
        
        if status == .beganUploading {
            self.displayWarningToast(message: "Began Uploading", duration: 2.0, toastSuperview: self.timelineView ?? self.view)
            
        }
        else {
            print( "Something strange" )
        }
    }
    
    func didReceiveErrorWhenDeletingPhotographNotification( sender : Notification ) {
        guard let senderData = sender.userInfo else {
            return
        }
        
        guard let status = senderData[NotificationKeys.PhotoDelete.status] as? PhotoDeleteStatus else {
            return
        }
        
        if status == .errorDeleting {
            if let error_string = senderData[NotificationKeys.PhotoDelete.error] as? String {
                self.displayWarningAlert(title: "Uh Oh", message: "Could not delete -> \(error_string)")
            }
            else {
                self.displayWarningAlert(title: "Uh Oh", message: "Could not delete photo")
            }
        }
        else {
            
        }
    }
    func didReceiveDidDeletePhotographNotifcation( sender : Notification ) {
        
        guard let senderData = sender.userInfo else {
            return
        }
        
        guard let status = senderData[NotificationKeys.PhotoDelete.status] as? PhotoDeleteStatus else {
            return
        }
        
        if status == .didDelete {
            self.displaySuccessToast(message: "Did delete photograph!", duration: 0.5, toastSuperview: self.timelineView ?? self.view )
            
        }
        else {
            self.displayWarningAlert(title: "Uh oh", message: "Could not delete photo. Reason unknown")
        }
    }
}

/*
    Toast Extensions
*/

extension UIViewController {
    
    func displayWarningAlert( title : String, message : String?) {
        
        let alert = SCLAlertView()
        
        alert.showWarning(title, subTitle: message ?? "")
    }
    func displayWarningToast( message : String, duration : TimeInterval?, toastSuperview : UIView?) {
        
        var style = ToastStyle()
        
        style.messageColor = Color.PAWarningTextColor
        style.titleColor = Color.PAWarningTextColor
        style.backgroundColor = Color.PAWarningColor
        
        let v : UIView! = toastSuperview ?? self.view
        
        v.makeToast(message, duration: duration ?? 3.0, position: ToastPosition.center, style: style)
    }
    func displayErrorToast( message : String, duration : TimeInterval?, toastSuperview : UIView?) {
        
        var style = ToastStyle()
        
        style.messageColor = Color.PADangerTextColor
        style.titleColor = Color.PADangerTextColor
        style.backgroundColor = Color.PADangerColor
        
        let v : UIView! = toastSuperview ?? self.view
    
        v.makeToast(message, duration: duration ?? 3.0, position: ToastPosition.center, style: style)

    }
    
    func displaySuccessToast( message : String, duration : TimeInterval?, toastSuperview : UIView?) {
        
        var style = ToastStyle()
        
        style.titleColor = Color.PASuccessTextColor
        style.messageColor = Color.PASuccessTextColor
        style.backgroundColor = Color.PASuccessColor
        
        let v : UIView! = toastSuperview ?? self.view
    
        v.makeToast(message, duration: duration ?? 3.0, position: ToastPosition.center, style: style)

    
    }
}

