//
//  PAAddPhotographViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/26/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import Eureka
import ImageRow


fileprivate struct PAPhotographValidationError {
    
    var errorMessage : String!
    var didSucceed : Bool = false
}

fileprivate struct InitialValues {
    
    var photoDate           : Date!
    var photoMaxDate        : Date!
    var photoMinDate        : Date!
    var photoDateConf       : Float!
    var photoTitle          : String!
    var photoDescription    : String!
    var confSliderSteps     : UInt!
    
    
    
}

class PAAddPhotoViewController : FormViewController {
    
    static let STORYBOARD_ID = "paaddphotoviewcontroller"
    
    let dateMan = PADateManager.sharedInstance
    let dataMan = PADataManager.sharedInstance
    
    var newPhotograph = PAPhotograph()
    fileprivate var selectedImageURL : URL?
    var currentRepository : PARepository?
    
    
    fileprivate var setupValues = InitialValues()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()
    }
    
    /*
        SETUP FUNCTIONS
    */
    private func _setup() {
        
        _setupInitialValues()
        _setupForm()
    }
    
    private func _setupForm() {
        
        /*
            General Information Section
        */
        let section_one_title = "General Photo Information"
        
        form +++ Section(section_one_title)
            <<< TextRow() {
                
                $0.title        = "Photo Title"
                $0.value        = self.setupValues.photoTitle
                $0.placeholder  = "Title"
                $0.tag          = Keys.Photograph.title
            }
        
            <<< TextAreaRow() {
                
                let row_height : CGFloat = 150.0
                
                $0.title            = "Photo Description"
                $0.placeholder      = "(Optional) Add a description for the photograph..."
                $0.value            = self.setupValues.photoDescription
                $0.textAreaHeight   = .dynamic(initialTextViewHeight: row_height)
                $0.tag              = Keys.Photograph.description
            }
        
        
        /*
            Date Information Section
        */
        let section_two_title = "Date Information"
        
        form +++ Section( section_two_title )
            
            <<< DateRow() {
                
                $0.title        = "Date Taken"
                $0.value        = self.setupValues.photoDate
                $0.minimumDate  = self.setupValues.photoMinDate
                $0.maximumDate  = self.setupValues.photoMaxDate
                $0.tag          = Keys.Photograph.dateTaken
            }
        
            <<< SliderRow() {
                
                $0.title        = "Date Taken Conf"
                $0.value        = self.setupValues.photoDateConf
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.steps        = self.setupValues.confSliderSteps
                $0.tag          = Keys.Photograph.dateTakenConf
            }
        
        
        
        /*
            Image Selection Section
        */
        let section_three_title = "Image"
        
        form +++ Section( section_three_title )
            <<< ImageRow() {
                $0.title = "Photograph"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum ]
                $0.tag          = Keys.Photograph.localPhotoURL
            }
            .cellUpdate { [weak self ] (cell , row) in
                
                cell.accessoryView?.layer.cornerRadius = 17.0
                cell.accessoryView?.frame = CGRect(x: 0.0, y: 0.0, width: 34.0, height: 34.0)
                
                if let img_url = row.imageURL {
                    
                    self?.selectedImageURL = img_url
                    
                    let message_string = String.init(format: "\nImage URL:\t%@\n", img_url.absoluteString)
                    print( message_string )
                    
                }
                else {
                    
                    let message_string = "\nThere was no image url\n"
                    print( message_string )
                }
            }
        
        
        /*
            Submit Row Section
        */
        
        form +++ Section()
            <<< ButtonRow() {
                
                $0.title = "Submit"
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                self?.submitPhotograph()
                
                print("\nYou selected the submit button!\n")
                
            }
            .cellUpdate { cell, row in
                cell.textLabel?.textColor = Color.PASuccessColor
            }
            <<< ButtonRow() {
             
                $0.title = "Cancel"
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
                .cellUpdate { cell, row in
                    
                    cell.textLabel?.textColor = Color.PADangerColor
            }
        
    }
    
    private func _setupInitialValues() {
        
        setupValues.photoDate           = dateMan.getDateFromYearInt(year: 1970)
        setupValues.photoMinDate        = dateMan.getDateFromYearInt(year: 1500)
        setupValues.photoMaxDate        = Date()
        
        setupValues.photoDateConf       = 0.4
        setupValues.photoTitle          = ""
        setupValues.photoDescription    = ""
        
        setupValues.confSliderSteps     = 100
    }
    
    
    
    /*
        ACTION HANDLERS
    */
    fileprivate func validateFormValuesForSubmission() -> PAPhotographValidationError {
        
        var errorInformation = PAPhotographValidationError()
        
        
        //  Pull out the information
        let values = form.values()
        
        guard let title_value = values[Keys.Photograph.title] as? String else {
            
            errorInformation.errorMessage = "Title was not set"
            errorInformation.didSucceed = false
            return errorInformation
        }
        
        guard title_value != "" else {
            errorInformation.errorMessage = "Title was not set"
            errorInformation.didSucceed = false
            return errorInformation
        }
        
        guard self.selectedImageURL != nil else {
            
            errorInformation.errorMessage = "There was no image selected!"
            errorInformation.didSucceed = false
            
            return errorInformation
        }
        
        guard let date_taken = values[Keys.Photograph.dateTaken] as? Date else {
            
            errorInformation.errorMessage = "Date taken was not set"
            errorInformation.didSucceed = false
            return errorInformation
        }
        errorInformation.didSucceed = true
        errorInformation.errorMessage = "No error"
        
        return errorInformation
    }
    
    fileprivate func populatePhotographWithValues() -> PAPhotographValidationError {
        
        let error_info = self.validateFormValuesForSubmission()
        
        if !error_info.didSucceed {
            
            return error_info
        }
        
        let values = form.values()
        
        self.newPhotograph.title = values[Keys.Photograph.title] as! String
        
        if let photo_description = values[Keys.Photograph.description] as? String {
            self.newPhotograph.longDescription = photo_description
        }
        
        self.newPhotograph.dateTaken = values[Keys.Photograph.dateTaken] as! Date
        
        self.newPhotograph.dateTakenConf = values[Keys.Photograph.dateTakenConf] as! Float
        
        self.newPhotograph.mainImage = (values[Keys.Photograph.localPhotoURL] as! UIImage)
        
        return error_info
    }
    
    func submitPhotograph() {
        
        let error_info = self.populatePhotographWithValues()
        
        if !error_info.didSucceed {
            return
        }
        
        
        if let repo = self.currentRepository {
            
            self.dataMan.addPhotographToRepositoryv2(newPhoto: self.newPhotograph, repository: repo)
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    func showUploadsForm() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let uploads_vc = storyboard.instantiateViewController(withIdentifier: PACurrentUploadsViewController.STORYBOARD_ID) as! PACurrentUploadsViewController
        
        self.present(uploads_vc, animated: true, completion: nil)
    }
}

extension PAAddPhotoViewController {
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}
