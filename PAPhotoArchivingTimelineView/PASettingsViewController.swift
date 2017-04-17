//
//  PASettingsViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by YUNFEI YANG on 4/10/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

class PASettingsViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var text: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupNavigationBar()
        // Do any additional setup after loading the view.
        _setupPanelButton()
        
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationManager.updateCurrentIndex(page: .settings)
        
        
    }
    private func _setupNavigationBar() {
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        
        self.navigationController!.navigationBar.barTintColor = Color.init(hex: "263F6A")   //MainApplicationColor
    }
    
    private func _setupPanelButton() {
        
        let panel_button = UIBarButtonItem(image: #imageLiteral(resourceName: "panel_button_white"), landscapeImagePhone: nil, style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        panel_button.tintColor = Color.white
        
        navigationItem.leftBarButtonItem = panel_button
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
