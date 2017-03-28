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

class PAPhotoInformationViewControllerv2 : FormViewController {
    
    static let STORYBOARD_ID = "PAPhotoInformationViewControllerv2StoryboardID"
    
    var currentRepository : PARepository?
    var currentPhotograph : PAPhotograph? {
        didSet {
            self.setupValues()
        }
    }
    
    var didSetImage = false
    
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
            Keys.Photograph.dateTakenConf : String.init(format: "%.2f", photo.dateTakenConf)
        ] as [String : Any]
        
        self.form.setValues(values)
        
    }
    private func _setup() {
        
        _setupForm()
        
        
        
        
        
    }
    
    private func _setupForm() {
        
        //  Constants
        
        
        
        
        //  Setup the first section that contains the image view header
        form +++ Section() { section in
            var header = HeaderFooterView<PAPhotoInformationHeaderView>(.class)
            header.height = {PAPhotoInformationHeaderView.VIEW_HEIGHT}
            
            header.onSetupView = { view , _ in
             
                view.backgroundColor = Color.red
                view.delegate = self
                
                if let photo = self.currentPhotograph {
                    
                    let image_url = URL.init(string: photo.mainImageURL)
                    
                    view.mainImageView.kf.setImage(    with: image_url,
                                                        placeholder: nil,
                                                        options: nil,
                                                        progressBlock: nil,
                                                        completionHandler: { image, error, cacheType, imageURL in
                                                            
//                                                            view.mainImageView.animation = Constants.Spring.Animations.fadeInDown
//                                                            view.mainImageView.duration = 0.6
//                                                            view.mainImageView.delay = 2.0
//                                                            view.mainImageView.animate()
                                                            
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
                $0.placeholder = "Enter a description"
                $0.tag = Keys.Photograph.description
                $0.disabled = true
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 10.0)
                
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
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Submit"
                $0.hidden = true
                
            }
                
            .onCellSelection { [ weak self ] ( cell, row ) in
                
                print("You chose to submit it!")
            }
        
            <<< ButtonRow() {
                $0.title = "Exit"
                
            }
            .cellUpdate { cell, row in
                cell.textLabel?.textColor = Color.red
                
                
            }
            .onCellSelection { [ weak self ] ( cell, row ) in
                print("Exiting")
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        
        
        
        self.setupValues()
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
}


extension PAPhotoInformationViewControllerv2 : PAPhotoInformationHeaderDelegate {
    
    func PAPhotoInformationHeaderDidTap() {
        print( "you tapped me!" )
    }
}
