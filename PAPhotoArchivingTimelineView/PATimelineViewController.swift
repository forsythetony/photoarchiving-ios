
//
//  PATimelineViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 3/19/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import Firebase

class PATimelineViewController: UIViewController, PAChromeCasterDelegate {
    
    var ref : FIRDatabaseReference!
    var repositories : [FIRDataSnapshot]! = []
    var storageRef: FIRStorageReference!
    let chromecaster = PAChromecaster.sharedInstance
    
    var currentRepository : PARepository? {
        didSet {
            self.setupTimelineView()
        }
    }
    
    fileprivate var _refHandle: FIRDatabaseHandle!
    
    var can_use : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        chromecaster.delegate = self
        
        
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
        
        
        self.navigationController?.navigationItem.PAClearBackButtonTitle()
    }
    
    func setupTimelineView() {
        var viewRect = self.view.bounds
        viewRect.origin.x = 0.0
        viewRect.origin.y = 0.0
        
        
        let rInfo = self.currentRepository ?? PARepository.Mock1()
        
        let timelineView = PATimelineView(frame: viewRect, repoInfo: rInfo)
        timelineView.delegate = self
        
        
        self.title = rInfo.title
        
        self.view.addSubview(timelineView)
        
        
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
    
}

extension PATimelineViewController : PATimelineViewDelegate {
    
    func PATimelineViewPhotographWasTapped(info: PAPhotograph) {
        
        TFLogger.log(logString: "Tapping image with information", arguments: info.getPhotoInfoData().description)
        //self.chromecaster.sendPhoto(photo: info)
        self.performSegue(withIdentifier: Constants.SegueIDs.ToPhotoInformation, sender: info)
    }
}
