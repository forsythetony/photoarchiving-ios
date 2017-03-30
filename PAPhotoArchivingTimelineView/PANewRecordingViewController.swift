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

fileprivate struct ButtonKeys {
    
    static let createNewRecording = "createNewRecordingButton"
    static let stopRecording = "stopRecordingButton"
    static let beginRecording = "beginRecordingButton"
    static let exit = "exitButton"
    static let submit = "submitButton"
    
}
class PANewRecordingViewController : FormViewController {
    
    static let STORYBOARD_ID = "PANewRecordingViewControllerStoryboardID"
    
    let audioMan = PAAudioManager.sharedInstance
    let dataMan = PADataManager.sharedInstance
    
    var photoInformation : PAPhotograph?
    var newStory = PAStory()
    
    var isRecording = false {
        didSet {
            self.updateRecordingButtons()
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
                $0.value = "Some Title"
                $0.tag = Keys.Story.title
            }
        
        
        
        form +++ Section( "Record Story" )
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
                $0.title = "Stop Recording"
                $0.disabled = true
                $0.hidden = true
                $0.tag = ButtonKeys.stopRecording
            }
            .onCellSelection { [ weak self ] ( cell,row ) in
                
                self?.audioMan.stopRecording()
            }
            <<< ButtonRow() {
                $0.title    = "Create New Recording"
                $0.disabled = true
                $0.hidden = true
                $0.tag = ButtonKeys.createNewRecording
            }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                $0.tag = ButtonKeys.submit
            }
            .onCellSelection { [ weak self ] ( cell,row ) in
                
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
    }
    
    
    
    /*
        UPDATE HANDLERS
    */
    func updateRecordingButtons() {
        
        let beginRecordingButton = form.rowBy(tag: ButtonKeys.beginRecording)
        let stopRecordingButton = form.rowBy(tag: ButtonKeys.stopRecording)
        let createNewRecordingButton = form.rowBy(tag: ButtonKeys.createNewRecording)
        
        
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
        }
    }
}

extension PANewRecordingViewController : PAAudioManagerDelegate {
    func PAAudioManagerDidBeginPlayingStory(story: PAStory) {
        
    }
    func PAAudioManagerDidFinishPlayingStory(story: PAStory) {
        
    }
    func PAAudioManagerDidUpdateRecordingTime(time: TimeInterval, story: PAStory) {
        
    }
    func PAAudioManagerDidFinishRecording(total_time: TimeInterval, story: PAStory) {
        
        self.newStory = story
        self.isRecording = false
    }
    func PAAudioManagerDidUpdateStoryPlayTime(running_time: TimeInterval, total_time: TimeInterval, story: PAStory) {
        
    }
}
