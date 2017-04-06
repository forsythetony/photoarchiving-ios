//
//  PAUserProfileViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/6/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import SCLAlertView
import Kingfisher
import SnapKit

class PAUserProfileViewController: FormViewController {

    private let IMAGE_VIEW_HEIGHT : CGFloat  = 175.0
    private let IMAGE_VIEW_PADDING : CGFloat = 10.0
    
    private var TOTAL_HEADER_VIEW_HEIGHT : CGFloat {
        get {
            return IMAGE_VIEW_HEIGHT + (IMAGE_VIEW_PADDING * 2.0)
        }
    }
    private enum FieldTags : String {
        case email = "email"
        case dateJoined = "dateJoined"
        case repositoriesJoined = "reposJoined"
        case repositoriesCreated = "reposCreated"
        case photosUploaded = "photosUploaded"
        case storiesUploaded = "storiesUploaded"
        case firstname = "firstname"
        case lastname = "lastname"
        case birthdate = "birthdate"
    }
    private var edit_button : UIBarButtonItem!
    
    var isEditingForm : Bool = false {
        didSet {
            updateFormRows()
            updateEditButton()
        }
    }
    var user : PAUser {
        get {
            return PAGlobalUser.sharedInstace.user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    private func setValues() {
        
        let values = [
            FieldTags.email.rawValue : self.user.email,
            FieldTags.dateJoined.rawValue : self.user.dateJoinedString,
            FieldTags.repositoriesJoined.rawValue : self.user.repositoriesJoinedString,
            FieldTags.repositoriesCreated.rawValue : self.user.repositoriesCreatedString,
            FieldTags.photosUploaded.rawValue : self.user.photosUploadedString,
            FieldTags.storiesUploaded.rawValue : self.user.storiesUploadedString,
            FieldTags.firstname.rawValue : self.user.firstName,
            FieldTags.lastname.rawValue : self.user.lastName
        ] as [String : Any]
        
        form.setValues(values)
        tableView?.reloadData()
        
    }
    
    private func _setup() {
        
        _setupForm()
        _navigationSetup()
        _viewSetup()
    }
    
    private func _viewSetup() {
        
        _setupPanelButton()
        _setupEditButton()
        _setupNavBar()
        
        self.title = "Me"
    }
    
    private func _setupNavBar() {
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        
        self.navigationController!.navigationBar.barTintColor = Color.MainApplicationColor
    }
    private func _setupPanelButton() {
        
        let panel_button = UIBarButtonItem(image: #imageLiteral(resourceName: "panel_button_white"), landscapeImagePhone: nil, style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        panel_button.tintColor = Color.white
        
        navigationItem.leftBarButtonItem = panel_button
    }
    private func _setupEditButton() {
        
        edit_button = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(PAUserProfileViewController.didTapEditButton))
        edit_button.tintColor = Color.white
        edit_button.setTitleTextAttributes([NSForegroundColorAttributeName : Color.white], for: .normal)
        
        navigationItem.rightBarButtonItem = edit_button
        
        
    }
    private func _navigationSetup() {
        
        navigationManager.updateCurrentIndex(page: .profile)
    }
    private func _setupForm() {
        
        /*
            USER PROFILE IMAGE SECTION
        */
        
        form +++ Section() { section in
            
            section.header = {
                
                
                var header = HeaderFooterView<UIView>(.callback({
                    
                    let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: self.TOTAL_HEADER_VIEW_HEIGHT))
                    
                    
                    let imgView = UIImageView.init(frame: CGRect(x: 0.0, y: 0.0, width: self.IMAGE_VIEW_HEIGHT, height: self.IMAGE_VIEW_HEIGHT))
                    
                    imgView.contentMode = .scaleAspectFit
                    
                    view.addSubview(imgView)
                    
                    imgView.translatesAutoresizingMaskIntoConstraints = false
                    imgView.clipsToBounds = true
                    imgView.layer.cornerRadius = self.IMAGE_VIEW_HEIGHT / 2.0
                    
                    LayoutConstraint.activate([
                        imgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        imgView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                        imgView.heightAnchor.constraint(equalToConstant: self.IMAGE_VIEW_HEIGHT),
                        imgView.widthAnchor.constraint(equalToConstant: self.IMAGE_VIEW_HEIGHT)
                        ])
                    
                    
                    let img_url_string = self.user.profileImageURL
                    
                    let img_url = URL(string: img_url_string)
                    
                    
                    imgView.kf.setImage(with: img_url)
                    
                    
                    return view
                    
                }))
                header.height = { self.TOTAL_HEADER_VIEW_HEIGHT }
                
                return header
            }()
        }
            <<< TextRow() {
                $0.title = "First Name"
                $0.disabled = true
                $0.tag = FieldTags.firstname.rawValue
            }
            <<< TextRow() {
                $0.title = "Last Name"
                $0.disabled = true
                $0.tag = FieldTags.lastname.rawValue
            }
            <<< DateInlineRow() {
                $0.title = "Date Taken"
                $0.value = Date()
            }
            <<< TextRow() {
                $0.title = "Email"
                $0.disabled = true
                $0.tag = FieldTags.email.rawValue
            }
            <<< TextRow() {
                $0.title = "Date Joined"
                $0.disabled = true
                $0.tag = FieldTags.dateJoined.rawValue
        }
        
        
        form +++ Section("Stats")
            <<< TextRow() {
                
                $0.title = "Repositories Joined"
                $0.tag = FieldTags.repositoriesJoined.rawValue
            }
            <<< TextRow() {
                $0.title = "Repositories Created"
                $0.tag = FieldTags.repositoriesCreated.rawValue
            }
            <<< TextRow() {
                $0.title = "Photos Uploaded"
                $0.tag = FieldTags.photosUploaded.rawValue
            }
            <<< TextRow() {
                $0.title = "Stories Uploaded"
                $0.tag = FieldTags.storiesUploaded.rawValue
            }
        
        
        
        
        
        setValues()
        
    }
    private func updateEditButton() {
        
        var title = "Edit"
        
        
        if isEditingForm {
            title = "Save"
        }
        
        edit_button.title = title
        
        
    }
    private func rowByID( id : FieldTags) -> BaseRow? {
        
        return form.rowBy(tag: id.rawValue)
    }
    
    private func updateFormRows() {
        
        let nameRow = rowByID(id: .firstname)
        let lastNameRow = rowByID(id: .lastname)
        
        if isEditingForm {
            
            nameRow?.enableField()
            lastNameRow?.enableField()
        }
        else {
            nameRow?.disableField()
            lastNameRow?.disableField()
            
        }
    }
    private func collectValuesAndSubmit() {

        let vals = form.values()
        
        if let firstname = vals[FieldTags.firstname.rawValue] as? String {
            self.user.firstName = firstname
        }
        
        if let lastname = vals[FieldTags.lastname.rawValue] as? String {
            self.user.lastName = lastname
        }
        
        if let birthdate = vals[FieldTags.birthdate.rawValue] as? Date {
            self.user.birthDate = birthdate
        }
        

        PADataManager.sharedInstance.updateUserValues(user: self.user)
        
        
        
    }
    func didTapEditButton() {
        
        if isEditingForm {
            collectValuesAndSubmit()
            
            isEditingForm = false
        }
        else {
            
            isEditingForm = true
        }
    }
}
