//
//  PAAddRepositoryViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/27/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import Eureka
import SCLAlertView

fileprivate struct FormKeys {
    static let choosePhotoButton = "choosePhotoButton"
    static let basicSection = "basicSection"
}

class PAAddRepositoryViewController : FormViewController {
    
    static let STORYBOARD_ID = "PAAddRepositoryViewControllerStoryboardID"
    
    
    var newRepository : PARepository = PARepository()
    let dateMan = PADateManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _setupListeners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _removeListeners()
    }
    /*
        SETUP FUNCTIONS
    */
    private func _setup() {
        
        _setupForm()
        
    }
    
    private func _setupListeners() {
        
        let c = NotificationCenter.default
        
        c.addObserver(self, selector: #selector(PAAddRepositoryViewController.didReceiveSuccessfulRepoUploadNotification(note:)), name: Notifications.didUploadNewRepository.name, object: nil)
    }
    
    private func _removeListeners() {
        
        NotificationCenter.default.removeObserver(self, name: Notifications.didUploadNewRepository.name, object: nil)
    }
    private func _setupForm() {
        
        //  DEFAULTS
        let default_start_date = self.dateMan.getDateFromYearInt(year: 1900)
        let default_end_date = self.dateMan.getDateFromYearInt(year: 2000)
        let default_repo_title = "A new repository"
        let default_description = "Some description"
        
        form +++ Section("General Information") { section in
            
            var header = HeaderFooterView<PACustomHeaderView>(.class)
            header.height = { 0.0 }
            section.tag = FormKeys.basicSection
            //section.header = header
        }
            <<< TextRow() {
                
                $0.title        = "Title"
                $0.placeholder  = "Repository Title"
                $0.value        = ""
                $0.tag          = Keys.Repository.title
            }
            <<< TextAreaRow() {
                
                $0.title            = "Description"
                $0.value            = ""
                $0.textAreaHeight   = .dynamic(initialTextViewHeight: 90.0)
                $0.placeholder      = "A short description of this repository"
                $0.tag              = Keys.Repository.longDescription
            }
            <<< ButtonRow() {
                $0.title = "Choose Thumbnail"
                $0.hidden = true
                
            }
        
        form +++ Section("Date Information")
            <<< DateInlineRow() {
                
                $0.title        = "Start Date"
                $0.minimumDate  = self.dateMan.getDateFromYearInt(year: 1500)
                $0.maximumDate  = Date()
                $0.value        = default_start_date
                $0.tag          = Keys.Repository.startDate
            }
            <<< DateInlineRow() {
                
                $0.title        = "End Date"
                $0.minimumDate  = self.dateMan.getDateFromYearInt(year: 1500)
                $0.maximumDate  = Date()
                $0.value        = default_end_date
                $0.tag          = Keys.Repository.endDate
            }
        
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                print("\nYou tapped the submit button!\n")
                
                if let error = self?.pullUserInputIntoRepository() {
                    self?.handleErrorMessage(error_message: error)
                }
                else {
                    
                    PADataManager.sharedInstance.uploadNewRepository(repository: (self?.newRepository)!)
                }
                
            }
            .cellUpdate { (cell, row) in
                cell.textLabel?.textColor = Color.PASuccessTextColor
                cell.backgroundColor = Color.PASuccessColor
            }
        
            <<< ButtonRow() {
                $0.title = "Cancel"
            }
            .onCellSelection { [ weak self ] ( cell, row ) in

                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            .cellUpdate { (cell, row) in
                
                cell.textLabel?.textColor = Color.PAWarningTextColor
                cell.backgroundColor = Color.PAWarningColor
            }
    }
    
    /*
        ERROR HANDLING
    */
    func handleErrorMessage( error_message : String ) {
        print( String.init(format: "\n%@\n", error_message) )
    }
    
    /*
        ACTION HANDLERS
    */
    func validateUserInput() -> String? {
        
        let values = form.values()
        
        //  Make sure that the start date is before the end date
        guard   let start_date = values[Keys.Repository.startDate] as? Date,
                let end_date = values[Keys.Repository.endDate] as? Date else
        {
                
            let error_message = "Either the start date or end date were not set!"
            return error_message
        }
        
        guard start_date.isGreaterThanDate(date: end_date) else
        {
            
            let error_message = "Your start date is greater than your end date!"
            return error_message
        }
        
        //  Make sure the title value is not nil or empty
        guard let title = values[Keys.Repository.title] as? String else {
            
            let error_message = "The title value was not set!"
            return error_message
        }
        
        guard title != "" else {
            
            let error_message = "The title was empty!"
            return error_message
        }
        
        return nil
        
    }
    
    func pullUserInputIntoRepository() -> String? {
        
        if let error = validateUserInput()
        {
            return error
        }
        
        let values = form.values()
        
        //  General Information
        self.newRepository.title            = values[Keys.Repository.title] as! String
        self.newRepository.longDescription  = values[Keys.Repository.longDescription] as! String
        
        
        //  Boundary Dates
        self.newRepository.startDate    = (values[Keys.Repository.startDate] as! Date)
        self.newRepository.endDate      = (values[Keys.Repository.endDate] as! Date)
        
        return nil
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    func showImagePicker() {
        
    }
    
    func didReceiveSuccessfulRepoUploadNotification( note : Notification ) {
        
        let alert = SCLAlertView()
        
        
        alert.showSuccess("Uploaded!", subTitle: "Sucessfully added the repository!").setDismissBlock {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
