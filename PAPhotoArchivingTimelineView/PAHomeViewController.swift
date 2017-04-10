//
//  PAHomeViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 2/13/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit
import FirebaseAuth

class PAHomeViewController: UIViewController {

    
    @IBOutlet weak var logoutBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    let dataMan : PADataManager = PADataManager.sharedInstance
    let currentUser = PAGlobalUser.sharedInstace
    
    var notifications = [PADatabaseNotification]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        checkIfUserSignedIn()
        
        _setup()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _setupListeners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _removeListeners()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logoutBarButtonItem.tintColor = UIColor.white
        navigationManager.updateCurrentIndex(page: .home)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
         Here we should check if the user is signed in. If so then take no action
         other than loading the appropriate content. If the user not signed in then
         redirect to the sign in page. This should be a modal view transition.
     */
    func checkIfUserSignedIn() {

        //  This boolean value should be computed, I'm not going to bother with it 
        //  at the moment.
        var userIsSignedIn = false;
        
        
        //  FIXME:
        //      Want to replace this with a check on the data
        //      manager
        //  Check Firebase to see if the user is signed in
        if FIRAuth.auth()?.currentUser != nil {
            userIsSignedIn = true
        }
        else {
            //  If the user is not signed in then check the user defaults to see
            //  if there are saved credentials to sign the user in
            //  ADDME
        }
        
        if userIsSignedIn {
            
            //  If the user is already signed in then go ahead and load the data
            self.loadData()
        }
        else {
            
            //  If the user is not signed in then segue to the sign in page
            self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromHomeToSignInPage, sender: nil)
        }
    }

    /*
        This function should load the data for the user (acquired from Firebase) that will
        be displayed in the home page.
     */
    func loadData() {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //  Make sure that this segue has an identifier, otherwise just exit
        //  the function
        guard let segueIdentifier = segue.identifier else { return }
        
        switch segueIdentifier {
        case Constants.SegueIDs.SegueFromHomeToSignInPage:
            
            let dest = segue.destination as! LoginViewController
            
            dest.delegate = self
            
        case Constants.SegueIDs.SegueFromHomeToRegister:
            
            let dest = segue.destination as! RegisterPageViewController
            
            dest.delegate = self
            
        default:
            break
        }
        
    }
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        
        guard FIRAuth.auth()?.currentUser != nil else { return }
        
        //  FIXME:
        //      Want to catch errors here if they do occur
        try! FIRAuth.auth()!.signOut()
        
        
        //  FIXME:
        //      Want to replace this with a call to the actual
        //      data manager.
        checkIfUserSignedIn()
    }
    
    

    
    /*
        SETUP FUNCTIONS
    */
    
    private func _setup() {
        
        _setupNavigationBar()
        _setupPanelButton()
        _setupTableView()
    }
    
    private func _setupNavigationBar() {
        
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        
        self.navigationController!.navigationBar.barTintColor = Color.MainApplicationColor
        logoutBarButtonItem.tintColor = UIColor.white
    }
    
    private func _setupPanelButton() {
        
        let panel_button = UIBarButtonItem(image: #imageLiteral(resourceName: "panel_button_white"), landscapeImagePhone: nil, style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        panel_button.tintColor = Color.white
        
        navigationItem.leftBarButtonItem = panel_button
    }
    
    
    private func _setupTableView() {
        
        let notification_cell_nib = UINib(nibName: "PANotificationTableViewCell", bundle: Bundle.main)
        
        notificationsTableView.register(notification_cell_nib, forCellReuseIdentifier: PANotificationTableViewCell.REUSE_IDENTIFIER)
        
        
    }
   
    private func _setupData() {
        
        if dataMan.isConfigured {
            _beginObservingNotifications()
        }
        else {
            dataMan.configure()
        }
    }
    
    fileprivate func _beginObservingNotifications() {
        
        dataMan.beginObservingStories { (snapShot) in
            
            if let new_notification = PADatabaseNotification.buildFromSnapshot(snapshot: snapShot) {
                
                self.addNewNotification(notification: new_notification)
            }
        }
    }
    
    
    func addNewNotification( notification : PADatabaseNotification ) {
        
        
        self.notifications.insert(notification, at: 0)
        
        self.notificationsTableView.beginUpdates()
        
        let new_index_path = IndexPath(row: 0, section: 0)
        self.notificationsTableView.insertRows(at: [new_index_path], with: .left)
        
        self.notificationsTableView.endUpdates()
    }
    
    
    private func _setupListeners() {
        
        
        let d = NotificationCenter.default
        
        d.addObserver(  self,
                        selector: #selector(PAHomeViewController.didReceiveNewUserNotification(note:)),
                        name: Notifications.didCreateNewUser.name, 
                        object: nil)
        
    }
    
    private func _removeListeners() {
        
        let d = NotificationCenter.default
        
        let notificationNames = [
            Notifications.didCreateNewUser.name
        ]
        
        d.PARemoveAllNotificationsWithName(listener: self, names: notificationNames)
    }
    
    func didReceiveNewUserNotification( note : Notification) {
        
        
        let globalUser = PAGlobalUser.sharedInstace
        
        globalUser.reloadGlobalUser()
        
    }
}

/*
    TABLE VIEW DELEGATE AND DATASOURCE RESPONDERS
*/
extension PAHomeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PANotificationTableViewCell.REUSE_IDENTIFIER) as? PANotificationTableViewCell else {
            
            return UITableViewCell()
        }
        
        
        let cell_info = notifications[indexPath.row]
        
        let date_posted = PADateManager.sharedInstance.getDateString(date: cell_info.datePosted, formatType: .Pretty2)
        
        
        var notification_string = ""
        var notification_icon = #imageLiteral(resourceName: "default_notification_icon")
        
        switch cell_info.notificationType {
        case .photoAddedToRepository:
            notification_string = "Photo was added to repository"
            notification_icon = #imageLiteral(resourceName: "story_added_notification_icon")
            break
            
        case .storyAddedToRepository:
            notification_string = "Story was added to repository"
            notification_icon = #imageLiteral(resourceName: "story_added_notification_icon")
            break
            
        case .userCreatedRepository:
            notification_string = "User created repository"
            notification_icon = #imageLiteral(resourceName: "story_added_notification_icon")
            break
            
        case .userAddedFriend:
            notification_string = "User added friend"
            notification_icon = #imageLiteral(resourceName: "story_added_notification_icon")
            break
            
            
        default:
            break
        }
        
        
        cell.notificationTypeImageView.image    = notification_icon
        cell.textView.text                      = notification_string
        cell.datePostedLabel.text               = date_posted
        
        return cell
    }
}

extension PAHomeViewController : PALoginViewControllerDelegate {
    
    func PALoginViewControllerDidSignInSuccessfully() {
        
        //  First dismiss the view controller that is being presented
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        //  If the login was successful then begin to load the data for the user's
        //  home page
        self.loadData()
    }
    
    func PALoginViewControllerUserDidClickSignUp() {
        
        self.presentedViewController?.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromHomeToRegister, sender: nil)
        })
    }
    
    
}

extension PAHomeViewController : PARegisterControllerDelegate {
    
    func PARegisterControllerDidSuccessfullySignInUser() {
        
        //  First dismiss the register view controller that is being presented
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        PAGlobalUser.sharedInstace.reloadGlobalUser()
    }
    
    func PARegisterControllerCouldNotSignInUser() {
        
        print("\nI could not sign in the user!")
    }
    
    func PARegisterViewControllerDidCancelSignUp() {
        
        self.presentedViewController?.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromHomeToSignInPage, sender: nil)
        })
        
    }
}
extension PAHomeViewController : PADataManagerDelegate {
    
    func PADataManagerDidCreateUser(new_user: PAUserUploadPackage?, error: Error?) {
        
    }
    
    internal func PADataManagerDidDeletePhotograph(photograph: PAPhotograph) {
        
    }

    internal func PADataManagerDidDeleteStoryFromPhotograph(story: PAStory, photograph: PAPhotograph) {
        
    }

    internal func PADataManagerDidUpdateProgress(progress: Double) {
        
    }

    internal func PADataManagerDidFinishUploadingStory(storyID: String) {
        
    }

    func PADataMangerDidConfigure() {
        _beginObservingNotifications()
    }
    
    func PADataManagerDidGetNewRepository(_ newRepository: PARepository) {
        //  I don't think there needs to be any implementation here
    }
    
    func PADataManagerDidSignInUserWithStatus(_ signInStatus: PAUserSignInStatus) {
        
        //  If the user was successfully signed in using the UserDefaults then
        //  we can allow the user to view the home page
        //  ADDME
    }
}
