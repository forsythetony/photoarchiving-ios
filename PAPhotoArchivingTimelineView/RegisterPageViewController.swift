//
//  RegisterPageViewController.swift
//  UserLoginAndRegisttation
//
//  Created by YUNFEI YANG on 2/9/17.
//  Copyright © 2017 YUNFEI YANG. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import Firebase
import SCLAlertView
import SwiftSpinner

protocol PARegisterControllerDelegate {
    func PARegisterControllerDidSuccessfullySignInUser()
    func PARegisterControllerCouldNotSignInUser()
    func PARegisterViewControllerDidCancelSignUp()
}

class RegisterPageViewController: FormViewController {
    
    var delegate    : PARegisterControllerDelegate?
    
    let dataMan     : PADataManager = PADataManager.sharedInstance
    
    private let dateMan = PADateManager.sharedInstance
    
    var newUser = PAUserUploadPackage()
    
    private var _selectedImageURL : URL?
    private var backgroundImageView : UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _setFormFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    
    
    /*
        SETUP FUNCTIONS
    */
    private enum FieldTags : String {
        
        case email
        case password
        case passwordConfirmation
        case birthdate
        case firstName
        case lastName
        case profileImage
    }
    private enum ButtonTags : String {
        
        case submit
        case clear
        case cancel
    }
    
    private func _setup() {
        _setupViews()
        _setupForm()
    }
    
    private func _setupViews() {
        
        _setupBackgroundImageView()
        _setupTableViewContraints()
        tableView?.backgroundColor = Color.clear
        
    }
    private func _setupBackgroundImageView() {
        
        backgroundImageView = UIImageView(frame: CGRect.zero)
        backgroundImageView.contentMode = .center
        backgroundImageView.image = UIImage(named: "main_background")
        
        guard let v = self.view else { return }
        
        v.addSubview(backgroundImageView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: v.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: v.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: v.rightAnchor)
        ])
        
        v.sendSubview(toBack: backgroundImageView)
        
    }
    
    private func _setupTableViewContraints() {
        
        guard let t = tableView else { return }
        
        let topPadding : CGFloat = 20.0
        
        t.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            t.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topPadding),
            t.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
            t.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0),
            t.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0)
        ])
        
    }
    private func _setFormFirstResponder() {
        
        let first_responder_tag = FieldTags.email.rawValue
        
        
        let row : BaseRow! = form.rowBy(tag: first_responder_tag)
        
        row.baseCell.cellBecomeFirstResponder()
    }
    
    private func _setupForm() {
        
        
        //  Email and Password Section
        
        let email_and_password_section_title = "Email and Password"
        
        form +++ Section( email_and_password_section_title ){ section in
            
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    
                    let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: RegisterPageViewController.SECTION_HEADER_HEIGHT))
                    
                    
                    view.backgroundColor = RegisterPageViewController.SECTION_BACKGROUND_COLOR
                    
                    let label = UILabel(frame: view.bounds)
                    
                    view.addSubview(label)
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0),
                        label.topAnchor.constraint(equalTo: view.topAnchor),
                        label.rightAnchor.constraint(equalTo: view.rightAnchor),
                        label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                        ])
                    
                    label.text = email_and_password_section_title
                    label.textColor = RegisterPageViewController.SECTION_HEADER_TEXT_COLOR
                    label.font = RegisterPageViewController.SECTION_HEADER_FONT
                    label.backgroundColor = Color.clear
                    
                    return view
                }))
                
                header.height = { RegisterPageViewController.SECTION_HEADER_HEIGHT }
                
                return header
            }()
            }
            <<< TextRow() {
                
                $0.title    = "Email Address"
                $0.value    = ""
                $0.tag      = FieldTags.email.rawValue
                $0.add(rule: RuleEmail())
            }
            .cellUpdate { cell, row in
                
                cell.textField.autocapitalizationType = .none
                cell.textField.autocorrectionType = .no
                
                cell.textLabel?.font = RegisterPageViewController.REQUIRED_TITLE_FONT
                cell.textLabel?.textColor = RegisterPageViewController.REQUIRED_TITLE_COLOR
                
                cell.textField.font = RegisterPageViewController.VALUE_FONT
                cell.textField.textColor = RegisterPageViewController.VALUE_COLOR
                
            }
        
            <<< TextRow() {
                
                $0.title    = "Password"
                $0.value    = ""
                $0.tag      = FieldTags.password.rawValue
                
            }
            .cellUpdate { cell, row in
                cell.textField.isSecureTextEntry = true
                cell.textField.autocapitalizationType = .none
                cell.textField.autocorrectionType = .no
                
                
                cell.textLabel?.font = RegisterPageViewController.REQUIRED_TITLE_FONT
                cell.textLabel?.textColor = RegisterPageViewController.REQUIRED_TITLE_COLOR
                
                cell.textField.font = RegisterPageViewController.VALUE_FONT
                cell.textField.textColor = RegisterPageViewController.VALUE_COLOR
            }
        
            <<< TextRow() {
                
                $0.title    = "Confirm Password"
                $0.value    = ""
                $0.tag      = FieldTags.passwordConfirmation.rawValue
            }
            .cellUpdate { cell, row in
                
                cell.textField.isSecureTextEntry = true
                cell.textField.autocapitalizationType = .none
                cell.textField.autocorrectionType = .no
                
                
                cell.textLabel?.font = RegisterPageViewController.REQUIRED_TITLE_FONT
                cell.textLabel?.textColor = RegisterPageViewController.REQUIRED_TITLE_COLOR
                
                cell.textField.font = RegisterPageViewController.VALUE_FONT
                cell.textField.textColor = RegisterPageViewController.VALUE_COLOR
            }
        
        
        
        
        //  Profile Image View Section
        
        let profile_image_section_title = "Profile Image"
        
        form +++ Section( profile_image_section_title ){ section in
            
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    
                    let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: RegisterPageViewController.SECTION_HEADER_HEIGHT))
                    
                    view.backgroundColor = RegisterPageViewController.SECTION_BACKGROUND_COLOR
                    
                    let label = UILabel(frame: view.bounds)
                    
                    view.addSubview(label)
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0),
                        label.topAnchor.constraint(equalTo: view.topAnchor),
                        label.rightAnchor.constraint(equalTo: view.rightAnchor),
                        label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                        ])
                    
                    label.text = profile_image_section_title
                    label.textColor = RegisterPageViewController.SECTION_HEADER_TEXT_COLOR
                    label.font = RegisterPageViewController.SECTION_HEADER_FONT
                    label.backgroundColor = Color.clear
                    
                    return view
                }))
                
                header.height = { RegisterPageViewController.SECTION_HEADER_HEIGHT }
                
                return header
            }()
            }
            <<< ImageRow() {
                $0.title = "Photograph"
                $0.sourceTypes = [.PhotoLibrary ]
                $0.tag          = FieldTags.profileImage.rawValue
                
                }
                .cellUpdate { [weak self ] (cell , row) in
                    
                    cell.accessoryView?.layer.cornerRadius = 17.0
                    cell.accessoryView?.frame = CGRect(x: 0.0, y: 0.0, width: 34.0, height: 34.0)
                    
                    if let img_url = row.imageURL {
                        
                        self?._selectedImageURL = img_url
                        
                        let message_string = String.init(format: "\nImage URL:\t%@\n", img_url.absoluteString)
                        print( message_string )
                    }
                    else {
                        
                        let message_string = "\nThere was no image url\n"
                        print( message_string )
                    }
                    
                    
                    cell.textLabel?.font = RegisterPageViewController.REQUIRED_TITLE_FONT
                    cell.textLabel?.textColor = RegisterPageViewController.REQUIRED_TITLE_COLOR
                    
                }
        
        
        
        //  Personal Information
        
        let personal_info_section_title = "Personal Information"
        
        form +++ Section( personal_info_section_title ) { section in
         
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    
                    let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: RegisterPageViewController.SECTION_HEADER_HEIGHT))
                    
                    view.backgroundColor = RegisterPageViewController.SECTION_BACKGROUND_COLOR
                    
                    let label = UILabel(frame: view.bounds)
                    
                    view.addSubview(label)
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0),
                        label.topAnchor.constraint(equalTo: view.topAnchor),
                        label.rightAnchor.constraint(equalTo: view.rightAnchor),
                        label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    ])
                    
                    label.text = personal_info_section_title
                    label.textColor = RegisterPageViewController.SECTION_HEADER_TEXT_COLOR
                    label.font = RegisterPageViewController.SECTION_HEADER_FONT
                    label.backgroundColor = Color.clear
                    
                    return view
                }))
                
                header.height = { RegisterPageViewController.SECTION_HEADER_HEIGHT }
                
                return header
            }()
        }
            <<< TextRow() {
                
                $0.title    = "First Name"
                $0.value    = ""
                $0.tag      = FieldTags.firstName.rawValue
            }
            .cellUpdate { cell, row in
                
                
                cell.textLabel?.font = RegisterPageViewController.OPTIONAL_TITLE_FONT
                cell.textLabel?.textColor = RegisterPageViewController.OPTIONAL_TITLE_COLOR
                
                cell.textField.font = RegisterPageViewController.VALUE_FONT
                cell.textField.textColor = RegisterPageViewController.VALUE_COLOR
                
            }
            <<< TextRow() {

                $0.title    = "Last Name"
                $0.value    = ""
                $0.tag      = FieldTags.lastName.rawValue
            }
            .cellUpdate { cell, row in
                cell.textLabel?.font = RegisterPageViewController.OPTIONAL_TITLE_FONT
                cell.textLabel?.textColor = RegisterPageViewController.OPTIONAL_TITLE_COLOR
                
                cell.textField.font = RegisterPageViewController.VALUE_FONT
                cell.textField.textColor = RegisterPageViewController.VALUE_COLOR
            }
        
            <<< DateInlineRow() {
                
                $0.title = "Birthdate"
                $0.value = self.dateMan.getDateFromYearInt(year: 1993)
                $0.tag = FieldTags.birthdate.rawValue
            }
            .cellUpdate { cell, row in
                    
                cell.textLabel?.font = RegisterPageViewController.OPTIONAL_TITLE_FONT
                cell.textLabel?.textColor = RegisterPageViewController.OPTIONAL_TITLE_COLOR
                
                cell.detailTextLabel?.font = RegisterPageViewController.VALUE_FONT
                cell.detailTextLabel?.textColor = RegisterPageViewController.VALUE_COLOR
            }
        
        
        let button_section_title = ""
        
        form +++ Section( button_section_title )
            <<< ButtonRow() {
                
                $0.title = "Submit"
                $0.tag = ButtonTags.submit.rawValue
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor = PAColors.successText.colorVal
                cell.backgroundColor = PAColors.success.colorVal
            }
            .onCellSelection { [weak self] cell, row in
                
                self?.submitData()
            }
            <<< ButtonRow() {
                $0.title = "Cancel"
                $0.tag = ButtonTags.cancel.rawValue
            }
            .cellUpdate { cell, row in
                
                cell.textLabel?.textColor = PAColors.dangerText.colorVal
                cell.backgroundColor = PAColors.danger.colorVal
                
            }
            .onCellSelection { [ weak self] (cell, row) in
                
                self?.delegate?.PARegisterViewControllerDidCancelSignUp()
            }
    }
    
    
    fileprivate func submitData() {
        
        guard gatherValues() else { return }
        
        SwiftSpinner.show("Creating User")
        
        FIRAuth.auth()?.createUser(withEmail: newUser.email, password: newUser.password, completion: { (user, error) in
            
            if let error = error {
                let error_message = String.init(format: "There was an error creating the user -> %@", error.localizedDescription)
                
                print( error_message.PAPadWithNewlines(padCount: 2) )
                
                self.displayErrorMessage(error_string: error_message)
                SwiftSpinner.hide()
                
                return
            }
            
            self.dataMan.delegate = self
            
            guard let new_user_id = user?.uid else {
                let error_message = String.init(format: "There was an error creating the user -> %@", "Couldn't get the user id")
                
                print( error_message.PAPadWithNewlines(padCount: 2) )
                
                self.displayErrorMessage(error_string: error_message)
                SwiftSpinner.hide()
                
                return
            }
            
            self.newUser.uid = new_user_id
            
            self.dataMan.createNewUser(new_user: self.newUser)
            
        })
        
        
    }
    
    fileprivate func validateValues() -> Bool {
        
        let values = form.values()
        
        if let email_value = values[FieldTags.email.rawValue] as? String {
            
            if email_value == "" {
                displayErrorMessage(error_string: "You need to enter an email address!")
                return false
            }
        }
        else {
            displayErrorMessage(error_string: "You need to enter an email address!")
            return false
        }
        
        if let password_value = values[FieldTags.password.rawValue] as? String, let password_conf_value = values[FieldTags.passwordConfirmation.rawValue] as? String {
            
            if password_value == "" || password_conf_value == "" {
                displayErrorMessage(error_string: "You need to enter a password and password confirmation value!")
                return false
            }
            
            if password_value != password_conf_value {
                
                let error_message = "The password and password confirmation values need to be equal!"
                
                displayErrorMessage(error_string: error_message)
                
                return false
            }
        }
        else {
            displayErrorMessage(error_string: "You need to enter a password and password confirmation value!")
            return false
        }
        
        
        return true
    }
    
    fileprivate func gatherValues() -> Bool {
        
        guard validateValues() else { return false }
        
        let values = form.values()
        
        newUser.email = values.getStringValue(k: FieldTags.email.rawValue)
        newUser.password = values.getStringValue(k: FieldTags.password.rawValue)
        newUser.birthDate = values.getFirebaseDateValue(k: FieldTags.birthdate.rawValue)
        newUser.firstName = values.getStringValue(k: FieldTags.firstName.rawValue)
        newUser.lastName = values.getStringValue(k: FieldTags.lastName.rawValue)
        
        newUser.profileImageTemp = values[FieldTags.profileImage.rawValue] as? UIImage
        
        
        return true
    }
    fileprivate func displayErrorMessage( error_string : String ) {
        
        let alert = SCLAlertView()
        
        alert.showWarning("Error", subTitle: error_string)
    }
    
    fileprivate func displaySuccessMessage( success_message : String, dismissBlock : @escaping () -> Void ) {
        
        let alert = SCLAlertView()
        
        alert.showSuccess("Success!", subTitle: success_message).setDismissBlock(dismissBlock)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension RegisterPageViewController : PADataManagerDelegate {
    func PADataManagerDidCreateUser(new_user: PAUserUploadPackage?, error: Error?) {
        
        SwiftSpinner.hide()
        
        
        if let error = error {
            
            let error_message = String.init(format: "Error uploading user -> %@", error.localizedDescription)
            
            print( error_message.PAPadWithNewlines(padCount: 2) )
            
            self.displayErrorMessage(error_string: error_message)
            
            return
        }
        
        guard let new_user = new_user else {
            let error_message = String.init(format: "Error uploading user -> %@", "Could not get new_user")
            
            print( error_message.PAPadWithNewlines(padCount: 2) )
            
            self.displayErrorMessage(error_string: error_message)
            
            return
        }
        
        
        let success_message = String.init(format: "Successfully uploaded user with id -> %@", new_user.uid)
        
        print( success_message.PAPadWithNewlines(padCount: 2) )
        
        self.displaySuccessMessage(success_message: success_message) { 
            
            
            
            
            self.delegate?.PARegisterControllerDidSuccessfullySignInUser()
        }
        
        
    }
    
    internal func PADataManagerDidDeletePhotograph(photograph: PAPhotograph) {
        
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
    func PADataManagerDidDeleteStoryFromPhotograph(story: PAStory, photograph: PAPhotograph) {
        
        
    }
}

//  Constants
extension RegisterPageViewController {
    
    @nonobjc static var SECTION_HEADER_HEIGHT : CGFloat = 40.0
    
    @nonobjc static var SECTION_HEADER_FONT : UIFont {
        get {
            let font_size : CGFloat = 15.0
            
            return UIFont.PABoldFontWithSize(size: font_size)
        }
    }
    
    @nonobjc static var SECTION_HEADER_TEXT_COLOR : Color {
        
        return Color.white
    }
    
    @nonobjc static var SECTION_BACKGROUND_COLOR : Color {
        
        return Color.clear
    }
    
    @nonobjc static var OPTIONAL_TITLE_FONT : UIFont {
        
        let font_size : CGFloat = 15.0
        
        return UIFont.PARegularFontWithSize(size: font_size)
    }
    
    @nonobjc static var OPTIONAL_TITLE_COLOR : Color {
        
        return Color.black
    }
    @nonobjc static var REQUIRED_TITLE_FONT : UIFont {
        let font_size : CGFloat = 15.0
        
        return UIFont.PARegularFontWithSize(size: font_size)
    }
    
    @nonobjc static var REQUIRED_TITLE_COLOR : Color {
        
        return Color.black
    }
    
    @nonobjc static var VALUE_FONT : UIFont {
        let font_size : CGFloat = 15.0
        
        return UIFont.PARegularFontWithSize(size: font_size)
    }
    
    @nonobjc static var VALUE_COLOR : Color {
        
        return Color.black
    }
}
