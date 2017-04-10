//
//  PASidePanelViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 4/6/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

import SnapKit

class PASidePanelViewController: UIViewController {
    
    var inboxButton : UIButton!
    var profileImageView : UIImageView!
    var favoritesButton : UIButton!
    var usernameTextLabel : UILabel!
    var navigationTableView : UITableView!
    var dividerLine : UIView!
    
    var navpages = [PANavigationPages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        _setupData()
        _setupViews()
        loadMockValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _setupListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _removeListeners()
    }
    private func _setupListeners() {
        
        let c = NotificationCenter.default
        
        c.addObserver(self, selector: #selector(PASidePanelViewController.didReceivePhotoDownloadedNotification(note:)), name: Notifications.didDownloadProfileImage.name, object: nil)
    }
    
    private func _removeListeners() {
        
        let c = NotificationCenter.default
        
        c.removeObserver(self, name: Notifications.didDownloadProfileImage.name, object: nil)
    }
    
    func didReceivePhotoDownloadedNotification( note : Notification) {
        
        DispatchQueue.main.async {
            
            self.profileImageView.image = PAGlobalUser.sharedInstace.profileImage
            self.usernameTextLabel.text = PAGlobalUser.sharedInstace.userEmail
        }
    }
    
    private func _setupData() {
        navpages = navigationManager.allPages
    }
    
    func _setupViews() {
        
        var frm = self.view.frame
        frm.size.width = 200.0
        self.view.frame = frm
        
        self.revealViewController().rearViewRevealWidth = self.view.frame.width
        self.revealViewController().rearViewRevealOverdraw = 0.0
        
        self.view.backgroundColor = Color.black
        
        let iconSize = 22.5
        
        self.view.snp.makeConstraints { (maker) in
            maker.width.equalTo(200.0)
            maker.height.equalTo(frm.height)
        }
        inboxButton = UIButton(frame: .zero)
        inboxButton.setImage(#imageLiteral(resourceName: "panel_button_white"), for: .normal)
        
        self.view.addSubview(inboxButton)
        
        var horizontalPadding = 10.0
        var verticalPadding = 15.0
        
        inboxButton.alpha = 0.0
        
        inboxButton.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: iconSize, height: iconSize))
            maker.left.equalTo(self.view).offset(horizontalPadding)
            maker.top.equalTo(self.view).offset(verticalPadding)
        }
        
        
        favoritesButton = UIButton(frame: .zero)
        favoritesButton.setImage(#imageLiteral(resourceName: "search_bar_icon_white"), for: .normal)
        
        self.view.addSubview(favoritesButton)
        
        favoritesButton.alpha = 0.0
        
        favoritesButton.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: iconSize, height: iconSize))
            maker.right.equalTo(self.view).offset(-horizontalPadding)
            maker.top.equalTo(self.view).offset(verticalPadding)
        }
        
        
        let profileImageSize = frm.width * 0.75
        let profileImageTopPadding = 40.0
        
        profileImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: profileImageSize, height: profileImageSize))
        
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = profileImageSize / 2.0
        profileImageView.clipsToBounds = true
        
        self.view.addSubview(profileImageView)
        
        //  Profile Image View Gesture Recognizer
        let tapper = UITapGestureRecognizer(target: self, action: #selector(PASidePanelViewController.didTapProfileImageView(sender:)))

        profileImageView.addGestureRecognizer(tapper)
        
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.snp.makeConstraints { (maker) in
            maker.width.equalTo(profileImageSize)
            maker.height.equalTo(profileImageSize)
            maker.top.equalTo(self.view).offset(profileImageTopPadding)
            maker.centerX.equalTo(self.view)
        }
        
        usernameTextLabel = UILabel(frame: .zero)
        usernameTextLabel.textAlignment = .center
        
        self.view.addSubview(usernameTextLabel)
        
        verticalPadding = 7.5
        horizontalPadding = 10.0
        let usernameTextLabelHeight = 40.0
        
        usernameTextLabel.snp.makeConstraints { (maker) in
            maker.height.equalTo(usernameTextLabelHeight)
            maker.left.equalTo(self.view.snp.left).offset(horizontalPadding)
            maker.right.equalTo(self.view.snp.right).offset(-horizontalPadding)
            maker.top.equalTo(profileImageView.snp.bottom).offset(verticalPadding)
        }
        
        let fontSize : CGFloat = 18.0
        
        usernameTextLabel.font = UIFont.PARegularFontWithSize(size: fontSize)
        usernameTextLabel.textColor = Color.PAWhiteOne
        usernameTextLabel.adjustsFontSizeToFitWidth = true
        
        dividerLine = UIView(frame: .zero)
        
        dividerLine.backgroundColor = Color.PAWhiteOne
        
        self.view.addSubview(dividerLine)
        
        dividerLine.snp.makeConstraints { (maker) in
            maker.height.equalTo(1.0)
            maker.width.equalTo(self.view).multipliedBy(0.45)
            maker.centerX.equalTo(self.view)
            maker.top.equalTo(usernameTextLabel.snp.bottom).offset(10.0)
        }
        
        
        navigationTableView = UITableView(frame: .zero)
        navigationTableView.dataSource = self
        navigationTableView.delegate = self
        self.view.addSubview(navigationTableView)
        
        navigationTableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(dividerLine.snp.bottom).offset(10.0)
            maker.left.equalTo(self.view).offset(horizontalPadding)
            maker.right.equalTo(self.view).offset(-horizontalPadding)
            maker.bottom.equalTo(self.view).offset(-horizontalPadding)
        }
        
        navigationTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationTableView.backgroundColor = UIColor.clear
        navigationTableView.separatorStyle = .none
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

/*
    ACTION HANDLERS
*/
extension PASidePanelViewController {
    
    func didTapProfileImageView( sender : UITapGestureRecognizer ) {
        
        print( "Posting the fake notification!".PAPadWithNewlines(padCount: 2) )
        
        PADataManager.sharedInstance.postFakeNotification()
    }
    
    
    
}
extension PASidePanelViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return navpages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.textAlignment = .center
        
        let i = indexPath.row
        
        var text_attributes =  [ String : Any ]()
        
        if i == navigationManager.currentIndex {
            
            text_attributes[NSForegroundColorAttributeName] = Color.PASuccessTextColor
        }
        else {
            text_attributes[NSForegroundColorAttributeName] = Color.PAWhiteOne
        }
        text_attributes[NSFontAttributeName] = UIFont.PABoldFontWithSize(size: 18.0)
        
        
        
        cell.textLabel?.attributedText = NSAttributedString(string: navpages[i].rawValue, attributes: text_attributes)
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selection = navpages[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        switch selection {
        case .home:
            performSegue(withIdentifier: Constants.SegueIDs.SegueFromMenuToHome, sender: nil)
            
        case .repositories:
            performSegue(withIdentifier: Constants.SegueIDs.SegueFromMenuToRepositories, sender: nil)
            
        case .myRepositories:
            performSegue(withIdentifier: Constants.SegueIDs.SegueFromMenuToMyRepositories, sender: nil)
            
        case .profile:
            performSegue(withIdentifier: Constants.SegueIDs.SegueFromMenuToMyProfile, sender: nil)
            
        case .people:
            performSegue(withIdentifier: Constants.SegueIDs.SegueFromMenuToPeople, sender: nil)
            
        default:
            break
        }
    }
}


extension PASidePanelViewController {
    
    func loadMockValues() {
        profileImageView.image = PAGlobalUser.sharedInstace.profileImage
        usernameTextLabel.text = PAGlobalUser.sharedInstace.userEmail
    }
}
