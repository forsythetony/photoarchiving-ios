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
import CoreLocation
import SCLAlertView

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
    
    private enum SectionTitles : String {
        case photograph     = "Photograph"
        case general        = "General Photo Information"
        case date           = "Date Information"
        case location       = "Location Information"
    }
    
    static let STORYBOARD_ID = "paaddphotoviewcontroller"
    
    private let myLocation = CLLocation(latitude: 38.575036, longitude: -90.354108)
    
    let dateMan = PADateManager.sharedInstance
    let dataMan = PADataManager.sharedInstance
    
    var newPhotograph = PAPhotograph()
    fileprivate var selectedImageURL : URL?
    var currentRepository : PARepository?
    
    var start_date : Date? {
        didSet {
            if let date_picker_row = self.form.rowBy(tag: Keys.Photograph.dateTaken) {
                
                date_picker_row.baseValue = start_date!
                date_picker_row.updateCell()
            }
        }
    }
    
    fileprivate var setupValues = InitialValues()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()
    }
    
    
    
    
    
    
    // MARK: Setup Functions
    
    private func _setup() {
        
        _setupTableviewConstraints()
        _setupInitialValues()
        _setupForm()
    }
    
    private func _setupTableviewConstraints() {
        
        
        guard let t = tableView else { return }
        
        
        t.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            t.topAnchor.constraint(equalTo: self.view.topAnchor, constant: Constants.statusBarHeight),
            t.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
            t.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
            t.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0)
            ])
    }
    private func _setupForm() {
        
        form +++ Section( SectionTitles.photograph.rawValue )
            <<< ImageRow() {
                $0.title = "Photograph"
                $0.sourceTypes = [.PhotoLibrary ]
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
            General Information Section
        */
        
        form +++ Section( SectionTitles.general.rawValue )
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
        
        form +++ Section( SectionTitles.date.rawValue )
            
            <<< DateInlineRow() {
                
                $0.title        = "Date Taken"
                $0.value        = self.start_date ?? self.setupValues.photoDate
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
            Photograph Location Information
        */
        
        form +++ Section( SectionTitles.location.rawValue )
            <<< PALocationRow() {
                $0.value    = self.myLocation
                $0.tag      = "location"
                $0.cell.delegate = self
            }
            <<< SliderRow() {
                $0.title        = "Location Conf"
                $0.value        = self.setupValues.photoDateConf
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.steps        = self.setupValues.confSliderSteps
                $0.tag          = Keys.Photograph.locationConf
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
                
                cell.textLabel?.textColor   = PAColors.successText.colorVal
                cell.backgroundColor        = PAColors.success.colorVal
            }
            <<< ButtonRow() {
             
                $0.title = "Cancel"
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor   = PAColors.dangerText.colorVal
                cell.backgroundColor        = PAColors.danger.colorVal
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
    
    
    // MARK: Update Functions

    fileprivate func updateImageRows() {
        
        let imageRow = form.rowBy(tag: "imagerow")
        
        if let image_url = self.selectedImageURL {
            
            let img = UIImage(named: image_url.absoluteString)
            
            imageRow?.baseValue = img
        }
        else {
            imageRow?.baseValue = nil
            
        }
        
        imageRow?.updateCell()
    }
    
    
    
    
    // MARK: Action Handlers

    fileprivate func validateFormValuesForSubmission() -> PAPhotographValidationError {
        
        var errorInformation = PAPhotographValidationError()
        
        
        //  Pull out the information
        let values = form.values()
        
        guard let title_value = values[Keys.Photograph.title] as? String else {
            
            errorInformation.errorMessage   = "Title was not set"
            errorInformation.didSucceed     = false
            
            return errorInformation
        }
        
        guard title_value != "" else {
            
            errorInformation.errorMessage   = "Title was not set"
            errorInformation.didSucceed     = false
            
            return errorInformation
        }
        
        guard self.selectedImageURL != nil else {
            
            errorInformation.errorMessage   = "There was no image selected!"
            errorInformation.didSucceed     = false
            
            return errorInformation
        }
        
        guard let _ = values[Keys.Photograph.dateTaken] as? Date else {
            
            errorInformation.errorMessage   = "Date taken was not set"
            errorInformation.didSucceed     = false
            
            return errorInformation
        }
        
        errorInformation.didSucceed     = true
        errorInformation.errorMessage   = "No error"
        
        return errorInformation
    }
    
    // MARK: Helper Functions

    fileprivate func populatePhotographWithValues() -> PAPhotographValidationError {
        
        let error_info = validateFormValuesForSubmission()
        
        if !error_info.didSucceed {
            
            return error_info
        }
        
        let values = form.values()
        
        newPhotograph.title = values[Keys.Photograph.title] as! String
        
        if let photo_description = values[Keys.Photograph.description] as? String {
            newPhotograph.longDescription = photo_description
        }
        
        newPhotograph.dateTaken     = values[Keys.Photograph.dateTaken]         as! Date
        newPhotograph.dateTakenConf = values[Keys.Photograph.dateTakenConf]     as! Float
        newPhotograph.mainImage     = (values[Keys.Photograph.localPhotoURL]    as! UIImage)
        
        if let coords = values["location"] as? CLLocation {
            
            newPhotograph.locationTaken.coordinates = coords.coordinate
            newPhotograph.locationTakenConf         = values[Keys.Photograph.locationConf] as! Float
        }
        
        return error_info
    }
    
    func submitPhotograph() {
        
        let error_info = populatePhotographWithValues()
        
        
        
        if !error_info.didSucceed {
            
            return
        }
        
        
        getLocationValues()
        
        
        
    }

    private func displayError( message: String, title : String? = "Error") {
        
        let alert = SCLAlertView()
        
        alert.showError(title!, subTitle: message)
    }
    
    private func getLocationValues() {
        
        guard let coord = self.newPhotograph.locationTaken.coordinates else { return }
        let e = self.newPhotograph
        guard let r = currentRepository else {
            displayError(message: "There was no repository!")
            return
        }
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(coord.getLocation) { (placemark, error) in
            
            if let error = error {
                
                let error_str = String.init(format: "Error getting location\nError:\t%@\n", error.localizedDescription)
                
                print( error_str.PAPadWithNewlines(padCount: 3) )
                return
            }
            
            
            if let pm = placemark {
                if pm.count > 0 {
                    
                    if let firstPM = pm[0] as? CLPlacemark {
                        
                        if let addressDict = firstPM.addressDictionary as? [AnyHashable : Any ] {
                            
                            if let country = addressDict["Country"] as? String {
                                e.locationTaken.country = country
                            }
                            
                            if let city = addressDict["City"] as? String {
                                e.locationTaken.city = city
                            }
                            
                            if let state = addressDict["State"] as? String {
                                e.locationTaken.state = state
                            }
                            
                            if let zip = addressDict["ZIP"] as? String {
                                e.locationTaken.zip = zip
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                }
            }
            
            if let repo = self.currentRepository {
                
                self.dataMan.addPhotographToRepositoryv2(newPhoto: self.newPhotograph, repository: repo)
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            
            
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
            return false
        }
    }
}

extension PAAddPhotoViewController : PALocationCellDelegate {
    
    var degreesDelta: CLLocationDegrees {
        get {
            return self.newPhotograph.iosData.degreesDelta
        }
    }
    
    func didUpdateDegreesDelta(delta: CLLocationDegrees) {
        self.newPhotograph.iosData.degreesDelta = delta
    }
}
