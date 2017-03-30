//
//  PANewRecordingViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/29/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import Eureka
import Kingfisher
import SCLAlertView

fileprivate struct ButtonKeys {
    
    static let createNewRecording = "createNewRecordingButton"
    static let stopRecording = "stopRecordingButton"
    static let beginRecording = "beginRecordingButton"
    static let exit = "exitButton"
    static let submit = "submitButton"
    static let trash = "trash"
    static let recordingInfo = "recordingInfo"
    
}
fileprivate struct TextboxKeys {
    
    static let currentRecordingTime = "currentRecordingTime"
    static let uploadProgress = "uploadProgress"
    
}
fileprivate enum FileUploadStatus {
    case notStarted, inProgress, completed, error
}
class PANewRecordingViewController : FormViewController {
    
    static let STORYBOARD_ID = "PANewRecordingViewControllerStoryboardID"
    
    let audioMan = PAAudioManager.sharedInstance
    let dataMan = PADataManager.sharedInstance
    
    var photoInformation : PAPhotograph?
    var newStory = PAStory()
    
    var currentRecordingTime = 0.0
    
    fileprivate var uploadState = FileUploadStatus.notStarted
    fileprivate var uploadProgress = 0.0
    
    var hasRecording = false
    
    var isRecording = false {
        didSet {
            self.updateRecordingButtons()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()
    }
    
    
    /*
        SETUP FUNCTIONS
    */
    private func _setup() {
        _setupData()
        _setupAudioRecording()
        _setupForm()
    }
    
    private func _setupData() {
        
        dataMan.delegate = self
        if let new_story_id = dataMan.getNewStoryUID() {
            self.newStory.uid = new_story_id
        }
        else {
            self.newStory.uid = ""
        }
    }
    private func _setupAudioRecording() {
        
        self.audioMan.delegate = self
    }
    private func _setupForm() {
        
        //  Constants
        
        
        //  Setup the first section that contains the image header
        form +++ Section() { section in
            
            var header = HeaderFooterView<PAPhotoInformationHeaderView>(.class)
            header.height = {PAPhotoInformationHeaderView.VIEW_HEIGHT}
            
            header.onSetupView = { view , _ in
                
                if let photo = self.photoInformation {
                    let image_url = URL.init(string: photo.mainImageURL)
                    
                    view.mainImageView.kf.setImage(with: image_url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                    
                }
                
            }
            
            section.header = header
        }
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Give the story a title..."
                $0.value = ""
                $0.tag = Keys.Story.title
            }
        
        
        
        form +++ Section( "Record Story" )
            <<< TextRow() {
                $0.title = "Recording Time"
                $0.value = 0.0.PATimeString
                $0.tag = TextboxKeys.currentRecordingTime
                $0.hidden = true
                $0.disabled = true
            }
            <<< TextRow() {
                $0.title = "Recording URL"
                $0.value = ""
                $0.hidden = true
                $0.disabled = true
                $0.tag = ButtonKeys.recordingInfo
            }
            <<< ButtonRow() {
                $0.title = "Begin Recording"
                $0.disabled = true
                $0.tag = ButtonKeys.beginRecording
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                if let curr_story = self?.newStory {
                    
                    if curr_story.uid != "" {
                        self?.audioMan.beginRecordingNewStory(story: curr_story)
                        self?.isRecording = true
                        self?.hasRecording = true
                        
                        self?.updateTrashRecordingButton()
                        
                        let debug_message = "Did begin recording"
                        print( debug_message )
                    }
                    else {
                        
                        print( "Could not begin recording because the UID was empty" )
                    }
                    
                }
                else {
                    print( "The story was set to nil..." )
                }
            }
            
            <<< ButtonRow() {
                $0.title = "Save Recording"
                $0.disabled = true
                $0.hidden = true
                $0.tag = ButtonKeys.stopRecording
            }
            .onCellSelection { [ weak self ] ( cell,row ) in
                
                self?.audioMan.stopRecording()
            }
            <<< ButtonRow() {
                $0.title = "Trash Recording"
                $0.disabled = true
                $0.hidden = true
                $0.tag = ButtonKeys.trash
            }
            .onCellSelection { [ weak self ] ( cell,row ) in
            
                self?.trashRecording()
            
            }
            <<< ButtonRow() {
                $0.title    = "Create New Recording"
                $0.disabled = true
                $0.hidden = true
                $0.tag = ButtonKeys.createNewRecording
            }
        
        form +++ Section()
            <<< TextRow() {
                $0.title = "Upload Progress"
                $0.value = 0.0.PAPercentString
                $0.tag = TextboxKeys.uploadProgress
                $0.hidden = true
                $0.disabled = true
                
            }
            <<< ButtonRow() {
                $0.title = "Submit"
                $0.tag = ButtonKeys.submit
            }
            .onCellSelection { [ weak self ] ( cell,row ) in
                self?.newStory.recordingLength = self?.currentRecordingTime ?? 0.0
                self?.setValuesForStory()
                if let photo = self?.photoInformation, let story = self?.newStory {
                    self?.dataMan.addNewStory(new_story: story, photograph: photo)
                }
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor = Color.PASuccessColor
            }
            <<< ButtonRow() {
                $0.title = "Exit"
                $0.tag = ButtonKeys.exit
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            .cellUpdate { cell, row in
                cell.textLabel?.textColor = Color.PADangerColor
            }
        
        
        self.updateRecordingButtons()
        self.updateUploadProgress()
    }
    
    private func trashRecording() {
        self.audioMan.stopRecording()
        self.newStory.recordingLength = 0.0
        self.newStory.tempRecordingURL = nil
        self.hasRecording = false
        self.isRecording = false
        
        self.updateTrashRecordingButton()
        self.updateRecordingInfoButton()
    }
    fileprivate func updateRecordingInfoButton() {
        let recordingInfoCell = form.rowBy(tag: ButtonKeys.recordingInfo)
        
        if hasRecording && !isRecording {
            if let temp_url = self.newStory.tempRecordingURL {
                recordingInfoCell?.baseValue = temp_url.absoluteString
                recordingInfoCell?.hidden = false
                
            }
        }
        else {
            recordingInfoCell?.hidden = true
        }
        
        recordingInfoCell?.evaluateHidden()
    }
    private func updateTrashRecordingButton() {
        let trashRecordingButton = form.rowBy(tag: ButtonKeys.trash)
        
        if hasRecording {
            trashRecordingButton?.hidden = false
            trashRecordingButton?.evaluateHidden()
            trashRecordingButton?.disabled = false
            trashRecordingButton?.evaluateDisabled()
        }
        else {
            trashRecordingButton?.hidden = true
            trashRecordingButton?.evaluateHidden()
            trashRecordingButton?.disabled = true
            trashRecordingButton?.evaluateDisabled()
        }
    }
    private func setValuesForStory() {
        
        let form_values = form.values()
        
        newStory.title = form_values[Keys.Story.title] as? String ?? ""
        
    }
    
    /*
        UPDATE HANDLERS
    */
    func updateRecordingButtons() {
        
        let beginRecordingButton = form.rowBy(tag: ButtonKeys.beginRecording)
        let stopRecordingButton = form.rowBy(tag: ButtonKeys.stopRecording)
        let createNewRecordingButton = form.rowBy(tag: ButtonKeys.createNewRecording)
        let currentTimeButton = form.rowBy(tag: TextboxKeys.currentRecordingTime)
        let trashRecordingButton = form.rowBy(tag: ButtonKeys.trash)
        let submitButton = form.rowBy(tag: ButtonKeys.submit)
        
        //  If you are currently recording then make sure to hide
        //  the begin recording and create new recording buttons
        if self.isRecording {
            
            beginRecordingButton?.hidden = true
            beginRecordingButton?.disabled = true
            beginRecordingButton?.evaluateHidden()
            beginRecordingButton?.evaluateDisabled()
            
            stopRecordingButton?.hidden = false
            stopRecordingButton?.disabled = false
            stopRecordingButton?.evaluateDisabled()
            stopRecordingButton?.evaluateHidden()
            
            createNewRecordingButton?.hidden = true
            createNewRecordingButton?.disabled = true
            createNewRecordingButton?.evaluateHidden()
            createNewRecordingButton?.evaluateDisabled()
            
            currentTimeButton?.hidden = false
            currentTimeButton?.evaluateHidden()
            
//            if hasRecording {
//                trashRecordingButton?.hidden = false
//                trashRecordingButton?.evaluateHidden()
//                trashRecordingButton?.disabled = false
//                trashRecordingButton?.evaluateDisabled()
//            }
//            else {
//                trashRecordingButton?.hidden = true
//                trashRecordingButton?.evaluateHidden()
//                trashRecordingButton?.disabled = true
//                trashRecordingButton?.evaluateDisabled()
//            }
//            
            
            submitButton?.disabled = true
            submitButton?.evaluateDisabled()
            
            
        }
        else {
            beginRecordingButton?.hidden = false
            beginRecordingButton?.disabled = false
            beginRecordingButton?.evaluateHidden()
            beginRecordingButton?.evaluateDisabled()
            
            stopRecordingButton?.hidden = true
            stopRecordingButton?.disabled = true
            stopRecordingButton?.evaluateDisabled()
            stopRecordingButton?.evaluateHidden()
            
            createNewRecordingButton?.hidden = true
            createNewRecordingButton?.disabled = true
            createNewRecordingButton?.evaluateHidden()
            createNewRecordingButton?.evaluateDisabled()
            
            currentTimeButton?.hidden = true
            currentTimeButton?.evaluateHidden()
//            
//            if self.hasRecording {
//                trashRecordingButton?.hidden = false
//                trashRecordingButton?.evaluateHidden()
//                trashRecordingButton?.disabled = false
//                trashRecordingButton?.evaluateDisabled()
//            }
//            else {
//                trashRecordingButton?.hidden = true
//                trashRecordingButton?.evaluateHidden()
//                trashRecordingButton?.disabled = true
//                trashRecordingButton?.evaluateDisabled()
//            }
            
            submitButton?.disabled = false
            submitButton?.evaluateDisabled()
        }
    }
    
    fileprivate func updateRecordingTime() {
        
        let rec_time_row = form.rowBy(tag: TextboxKeys.currentRecordingTime)
        
        rec_time_row?.baseValue = self.currentRecordingTime.PATimeString
        
        rec_time_row?.updateCell()
    }
    
    fileprivate func updateUploadProgress() {
        
        let upload_row = form.rowBy(tag: TextboxKeys.uploadProgress)
        
        switch self.uploadState {
        case .inProgress:
            
            upload_row?.baseValue = self.uploadProgress.PAPercentString
            upload_row?.hidden = false
            
            
        case .notStarted:
            
            upload_row?.baseValue = 0.0.PAPercentString
            upload_row?.hidden = true
            
        case .error:
            upload_row?.baseValue = "Error"
            upload_row?.hidden = false
            
        case .completed:
            upload_row?.baseValue = 100.0.PAPercentString
            upload_row?.hidden = false
            
        default:
            upload_row?.baseValue = 0.0.PAPercentString
            upload_row?.hidden = true
        }
        
        upload_row?.evaluateHidden()
        
        upload_row?.updateCell()
    }
}

extension PANewRecordingViewController : PADataManagerDelegate {
    func PADataManagerDidDeleteStoryFromPhotograph(story: PAStory, photograph: PAPhotograph) {
        
    }
    
    func PADataMangerDidConfigure() {
        
    }
    func PADataManagerDidUpdateProgress(progress: Double) {
        self.uploadState = .inProgress
        self.uploadProgress = progress
        self.updateUploadProgress()
        
    }
    func PADataManagerDidFinishUploadingStory(storyID: String) {
        SCLAlertView().showSuccess("Success!", subTitle: String.init(format: "Successfully uploaded the story titled '%@'", storyID))
        
        self.uploadState = .completed
    }
    func PADataManagerDidGetNewRepository(_ newRepository: PARepository) {
        
    }
    func PADataManagerDidSignInUserWithStatus(_ signInStatus: PAUserSignInStatus) {
        
    }
    
}
extension PANewRecordingViewController : PAAudioManagerDelegate {
    func PAAudioManagerDidBeginPlayingStory(story: PAStory) {
        
    }
    func PAAudioManagerDidFinishPlayingStory(story: PAStory) {
        
    }
    func PAAudioManagerDidUpdateRecordingTime(time: TimeInterval, story: PAStory) {
        
        self.currentRecordingTime = Double(time)
        
        self.updateRecordingTime()
        
    }
    func PAAudioManagerDidFinishRecording(total_time: TimeInterval, story: PAStory) {

        self.newStory = story
        self.hasRecording = true
        self.isRecording = false
        
        self.updateRecordingInfoButton()
    }
    func PAAudioManagerDidUpdateStoryPlayTime(running_time: TimeInterval, total_time: TimeInterval, story: PAStory) {
        
    }
}
