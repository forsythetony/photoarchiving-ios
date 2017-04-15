//
//  PAPhotoInformationPage.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/28/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import Foundation
import Eureka
import Kingfisher
import Spring
import GoogleCast
import SCLAlertView
import MapKit

extension CLLocationCoordinate2D {
    static var defaultLocation : CLLocationCoordinate2D {
        get {
            
            return CLLocationCoordinate2D(latitude: 38, longitude: -90)
        }
        
    }
    
    var getLocation : CLLocation {
        get {
            return CLLocation(latitude: self.latitude, longitude: self.longitude)
        }
    }
}

extension CLLocation {
    static var defaultLocation : CLLocation {
        get {
            let d = CLLocationCoordinate2D.defaultLocation
            
            return d.getLocation
        }
    }
}
class PAPhotoInformationViewControllerv2 : FormViewController {
    
    private enum ButtonIDs : String {
        case edit
        case submit
        case cancel
        case exit
        case viewStories
        case addStory
        case sliderRow
        case locationConfSlider
        case deletePhotograph
    }
    
    static let STORYBOARD_ID = "PAPhotoInformationViewControllerv2StoryboardID"
    
    var currentRepository : PARepository?
    var currentPhotograph : PAPhotograph? {
        didSet {
            print( currentPhotograph!.uid.PAPadWithNewlines(padCount: 2))
            self.setupValues()
        }
    }
    
    var editingPhotograph : PAPhotograph?
    
    var canEditPhotograph : Bool {
        get {
            let default_can_edit = false
            
            let data_man = PAGlobalUser.sharedInstace
            
            if let curr_user_id = currentPhotograph?.uploaderID {
                
                if curr_user_id == data_man.userID {
                    return true
                }
                
                return default_can_edit
            }
            
            return default_can_edit
        }
    }
    
    
    var didSetImage = false
    fileprivate var isEditingForm = false {
        didSet {
            updateButtons()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setup()
    }
    
    
    
    
    
    /*
        SETUP FUNCTIONS
    */
    func setupValues() {
        guard let photo = self.currentPhotograph else { return }
        
        let values : [String : Any] = [
            Keys.Photograph.title : photo.title,
            Keys.Photograph.description : photo.longDescription,
            Keys.Photograph.dateTaken : photo.dateTaken ?? Date(),
            Keys.Photograph.dateTakenConf : Double(photo.dateTakenConf).PAPercentString,
            ButtonIDs.sliderRow.rawValue : Float(photo.dateTakenConf),
            Keys.Photograph.locationLatitude : (photo.locationTaken.coordinates ?? CLLocationCoordinate2D.defaultLocation).getLocation,
            Keys.Photograph.locationConf : Double(photo.locationTakenConf).PAPercentString,
            ButtonIDs.locationConfSlider.rawValue : photo.locationTakenConf
        ] as [String : Any]
        
        self.form.setValues(values)
        self.tableView?.reloadData()
        
    }
    private func _setup() {
        
        _setupTableviewConstraints()
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
        
        //  Constants
        
        
        
        
        //  Setup the first section that contains the image view header
        form +++ Section() { section in
            var header = HeaderFooterView<PAPhotoInformationHeaderView>(.class)
            header.height = {PAPhotoInformationHeaderView.VIEW_HEIGHT}
            
            header.onSetupView = { view , _ in
                
                view.delegate = self
                
                if let photo = self.currentPhotograph {
                    
                    let image_url = URL.init(string: photo.mainImageURL)
                    
                    view.mainImageView.kf.setImage(    with: image_url,
                                                        placeholder: nil,
                                                        options: nil,
                                                        progressBlock: nil,
                                                        completionHandler: { image, error, cacheType, imageURL in
                                                            
                    })
                    self.didSetImage = true
                    
                }
            }
            
            section.header = header
        }
        
        form +++ Section( "Basic Information" )
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Placeholder"
                $0.disabled = true
                $0.tag = Keys.Photograph.title
            }
            <<< TextAreaRow() {
                
                $0.title = "Description"
                $0.placeholder = "No Description"
                $0.tag = Keys.Photograph.description
                $0.disabled = true
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 10.0)
                
            }
            .cellUpdate { [ weak self ] (cell, row) in
                
  
            }
        
        form +++ Section( "Date Taken" )
            <<< DateInlineRow() {
                
                $0.title = "Date Taken"
                $0.maximumDate = Date()
                $0.minimumDate = PADateManager.sharedInstance.getDateFromYearInt(year: 1500)
                $0.tag = Keys.Photograph.dateTaken
                $0.disabled = true
            }
            <<< TextRow() {
                $0.title = "Confidence"
                $0.tag = Keys.Photograph.dateTakenConf
                $0.disabled = true
            }
            <<< SliderRow() {
                $0.title = "Confidence"
                $0.value = 0.0
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.steps = 100
                $0.tag = ButtonIDs.sliderRow.rawValue
                $0.hidden = true
                
                $0.displayValueFor = { (floatVal) in
                 
                    if let f = floatVal {
                        
                        return Double(f).PAPercentString
                    }
                    
                    return Double(0.0).PAPercentString
                }
            }
        
        form +++ Section( "Location Information" )
            <<< PALocationRow() {
                $0.value = (self.currentPhotograph?.locationTaken.coordinates ?? CLLocationCoordinate2D.defaultLocation).getLocation
                $0.tag = Keys.Photograph.locationLatitude
                $0.disabled = true
                $0.cell.delegate = self
            }
            <<< TextRow() {
                $0.title = "Location Conf"
                $0.value = 0.0.PAPercentString
                $0.tag = Keys.Photograph.locationConf
                $0.hidden = false
            }
        
            <<< SliderRow() {
                $0.title = "Location Conf"
                $0.value = 0.0
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.tag = ButtonIDs.locationConfSlider.rawValue
                $0.steps = 100
                
                $0.displayValueFor = { (floatVal) in
                
                    if let f = floatVal {
                        return Double(f).PAPercentString
                    }
                    
                    return Double(0.0).PAPercentString
                }
                
                $0.hidden = true
                $0.disabled = true
            }
        form +++ Section( "Story Information" ) {
            
            $0.tag = "story"
            
        }
            <<< ButtonRow() {
                $0.title = "Add New Story"
                $0.tag = ButtonIDs.addStory.rawValue
            }
            .onCellSelection { [ weak self ] (cell, row) in
                
                let add_new_story_vc = UIStoryboard.PAMainStoryboard.instantiateViewController(withIdentifier: PANewRecordingViewController.STORYBOARD_ID) as! PANewRecordingViewController
                
                add_new_story_vc.photoInformation = self?.currentPhotograph
                
                self?.present(add_new_story_vc, animated: true, completion: nil)
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor = Color.PASuccessColor
            }
        
            <<< ButtonRow() {
                $0.title = "View Stories"
                $0.tag = ButtonIDs.viewStories.rawValue
            }
            .onCellSelection { [ weak self ] ( cell,row ) in
                
                let view_stories_vc = UIStoryboard.PAMainStoryboard.instantiateViewController(withIdentifier: PAStoriesViewController.STORYBOARD_ID) as! PAStoriesViewController
                
                view_stories_vc.currentPhotograph = self?.currentPhotograph
                
                self?.present(view_stories_vc, animated: true, completion: nil)
            }
        
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                $0.hidden = true
                $0.tag = ButtonIDs.submit.rawValue
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                print("You chose to submit it!")
                
                self?.submitEditingPhoto()
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor = Color.PASuccessTextColor
            }
            <<< ButtonRow() {
                $0.title = "Edit"
                $0.tag = ButtonIDs.edit.rawValue
                
                if self.canEditPhotograph {
                    $0.showAndEnable()
                }
                else {
                    $0.hideAndDisable()
                }
            }
            .cellUpdate { cell, row in
                
                
            }
            .onCellSelection{ [ weak self ] (cell,row) in
                
                self?.isEditingForm = true
                
                self?.setupEditingPhoto()
                
                self?.updateFields()
            }
            <<< ButtonRow() {
                
                $0.title = "Delete Photograph"
                $0.tag = ButtonIDs.deletePhotograph.rawValue
                
                if self.canEditPhotograph {
                    $0.showAndEnable()
                }
                else {
                    $0.hideAndDisable()
                }
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor   = PAColors.dangerText.colorVal
            }
            .onCellSelection{ [ weak self ] (cell,row) in
                
                
                self?.showDeletePhotographNotification()
            }
            <<< ButtonRow() {
                $0.title = "Exit"
                $0.tag = ButtonIDs.exit.rawValue
                
            }
            .cellUpdate { cell, row in
                cell.textLabel?.textColor = Color.PADangerColor
                
                
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                self?.trashCurrentEdit()
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
                
                
            }
            
            <<< ButtonRow() {
                $0.title = "Cancel"
                $0.tag = ButtonIDs.cancel.rawValue
            }
            .cellUpdate { cell, row in
                
            }
            .onCellSelection { [ weak self ] (cell,row) in
                
                self?.trashCurrentEdit()
            }
        
        isEditingForm = false
        self.setupValues()
    }
    
    
    private func updateButtons() {
        
        let submit  = getBaseRow(buttonID: .submit)
        let edit    = getBaseRow(buttonID: .edit)
        let delete  = getBaseRow(buttonID: .deletePhotograph)
        let cancel  = getBaseRow(buttonID: .cancel)
        let exit    = getBaseRow(buttonID: .exit)
        let viewStories = getBaseRow(buttonID: .viewStories)
        let addStory = getBaseRow(buttonID: .addStory)
        
        let storySection = form.sectionBy(tag: "story")
        
        if isEditingForm {
            
            
            submit?.showAndEnable()
            edit?.hideAndDisable()
            delete?.showAndEnable()
            cancel?.showAndEnable()
            exit?.showAndEnable()
            viewStories?.hideAndDisable()
            addStory?.hideAndDisable()
            
            storySection?.hidden = true
            storySection?.evaluateHidden()
        }
        else {
            submit?.hideAndDisable()
            
            if canEditPhotograph {
                edit?.showAndEnable()
                delete?.showAndEnable()
            }
            else {
                edit?.hideAndDisable()
                delete?.hideAndDisable()
            }
            
            cancel?.hideAndDisable()
            exit?.showAndEnable()
            viewStories?.showAndEnable()
            addStory?.showAndEnable()
            
            storySection?.hidden = false
            storySection?.evaluateHidden()
        }
        
        
    }
    
    private func updateFields() {
        
        let title = getBaseRow(fieldID: Keys.Photograph.title)
        let description = getBaseRow(fieldID: Keys.Photograph.description) as! TextAreaRow
        let dateTaken = getBaseRow(fieldID: Keys.Photograph.dateTaken)
        let dateConf = getBaseRow(fieldID: Keys.Photograph.dateTakenConf)
        let dateConfValue = getBaseRow(buttonID: .sliderRow)
        let locationValue = getBaseRow(fieldID: Keys.Photograph.locationLatitude)
        let locationConfTextRow = getBaseRow(fieldID: Keys.Photograph.locationConf)
        let locationSlider = getBaseRow(buttonID: .locationConfSlider)
        
        
        if isEditingForm {
            
            title?.enableField()
            
            
            description.placeholder = "Enter a description"
            description.updateCell()
            description.enableField()
            
            dateTaken?.enableField()
            dateConf?.hideAndDisable()
            dateConfValue?.showAndEnable()
            
            locationValue?.showAndEnable()
            locationConfTextRow?.hideAndDisable()
            locationSlider?.showAndEnable()
            
            
        }
        else {
            
            title?.disableField()
            
            description.placeholder = "No Description"
            description.updateCell()
            
            description.disableField()
            dateTaken?.disableField()
            dateConf?.enableField()
            dateConfValue?.hideAndDisable()
            
            locationValue?.disabled = true
            locationValue?.evaluateDisabled()
            
            locationValue?.hidden = false
            locationValue?.disabled = true
            locationValue?.evaluateHidden()
            locationValue?.evaluateDisabled()
            
            locationConfTextRow?.hidden = false
            locationConfTextRow?.evaluateHidden()
            locationConfTextRow?.disabled = true
            locationConfTextRow?.evaluateDisabled()
            
            locationSlider?.hideAndDisable()
            
        }
    }
    
    private func trashCurrentEdit() {
        
        guard isEditingForm else { return }
        
        editingPhotograph = nil
        isEditingForm = false
        
        updateFields()
        setupValues()
        
    }
    private func setupEditingPhoto() {
        
        editingPhotograph = nil
        
        if let p = currentPhotograph {
            
            editingPhotograph = p.getPhotographCopy()
            
        }
        else {
            displayError(message: "Couldn't get the current photograph!")
        }
    }
    
    private func submitEditingPhoto() {
        
        gatherValuesIntoEditingPhoto()
        
        
    }
    
    private func transferValues() {
        
        guard let e = editingPhotograph, let c = currentPhotograph else {
            displayError(message: "Something was weird")
            return
        }
        
        self.currentPhotograph?.title = e.title
        self.currentPhotograph?.longDescription = e.longDescription
        self.currentPhotograph?.dateTaken = e.dateTaken
        self.currentPhotograph?.dateTakenConf = e.dateTakenConf
        self.currentPhotograph?.locationTaken.coordinates = e.locationTaken.coordinates
        self.currentPhotograph?.locationTakenConf = e.locationTakenConf
        
        editingPhotograph = nil
        isEditingForm = false
        updateFields()
        setupValues()
        
    }
    private func gatherValuesIntoEditingPhoto() {
        
        guard let e = editingPhotograph else {
            displayError(message: "There was no editing photo to submit!")
            return
        }
        
        let vals = form.values()
        
        if let title = vals[Keys.Photograph.title] as? String {
            e.title = title
        }
        
        if let desc = vals[Keys.Photograph.description] as? String {
            e.longDescription = desc
        }
        
        if let dateTaken = vals[Keys.Photograph.dateTaken] as? Date {
            e.dateTaken = dateTaken
        }
        
        if let confidenceVal = vals[ButtonIDs.sliderRow.rawValue] as? Float {
            e.dateTakenConf = confidenceVal
        }
        
        if let coordinates = vals[Keys.Photograph.locationLatitude] as? CLLocation {
            e.locationTaken.coordinates = coordinates.coordinate
        }
        
        if let locationConf = vals[ButtonIDs.locationConfSlider.rawValue] as? Float {
            e.locationTakenConf = locationConf
        }
        
        getLocationValues()
        
    }
    private func displayError( message: String, title : String? = "Error") {
        
        let alert = SCLAlertView()
        
        alert.showError(title!, subTitle: message)
    }
    
    private func getBaseRow( buttonID : ButtonIDs ) -> BaseRow? {
        return form.rowBy(tag: buttonID.rawValue)
    }
    
    
    private func getBaseRow( fieldID : String ) -> BaseRow? {
        return form.rowBy(tag: fieldID)
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    private func getLocationValues() {
        
        guard let coord = self.currentPhotograph?.locationTaken.coordinates else { return }
        guard let e = self.editingPhotograph else { return }
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
            
            PADataManager.sharedInstance.updatePhotographValues(photo: e, repo: r)
            
            let alert = SCLAlertView()
            
            alert.showSuccess("Updated!", subTitle: "Updated photograph values").setDismissBlock {
                self.transferValues()
            }
            
            
        }
        
        
        
    }
    
    
    private func showDeletePhotographNotification() {
        
        
        
        //  FIXME:
        //      Put some logic in here to ask the user if they really
        //      want to delete the photograph THEN put some logic in
        //      callback to actually make the call to the datamanager
        //      to delete the photograph
        
        /*
            -------lOgIc hEre DuUuUuUuUuUuUdDddddeee ~+-~-~-~-~~~~~~
        */
    }
}

extension BaseRow {
    
    func enableField() {
        self.disabled = false
        self.evaluateDisabled()
    }
    
    func disableField() {
        self.disabled = true
        self.evaluateDisabled()
    }
}

extension PAPhotoInformationViewControllerv2 : PAPhotoInformationHeaderDelegate {
    
    func PAPhotoInformationHeaderDidTap() {
        print( "you tapped me!" )
    }
}

extension PAPhotoInformationViewControllerv2 : PALocationCellDelegate {
    
    var degreesDelta: CLLocationDegrees {
        get {
            if let d = self.currentPhotograph?.iosData.degreesDelta {
                return d
            }
            else {
                return 4.0
            }
        }
    }
    
    func didUpdateDegreesDelta(delta: CLLocationDegrees) {
        
        if self.isEditingForm {
            if let e = self.editingPhotograph {
                e.iosData.degreesDelta = delta
            }
        }
    }
}
