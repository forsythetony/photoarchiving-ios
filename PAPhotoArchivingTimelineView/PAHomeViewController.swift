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
    
    
    let dataMan : PADataManager = PADataManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = Color.MainApplicationColor
        logoutBarButtonItem.tintColor = UIColor.white
        
        // Do any additional setup after loading the view.
        checkIfUserSignedIn()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logoutBarButtonItem.tintColor = UIColor.white
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
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

    @IBAction func didTapRepositoriesButton(_ sender: Any) {
        
        //  Make sure that there is a current user logged in
        guard FIRAuth.auth()?.currentUser != nil else {
            
            let error_message = "There was no current user logged in so I can't go to the Repositories page. I shouldn't even be on this page!"
            print( error_message )
            return
        }
        
        //  Push the page with all the repositories on it
        self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromHomeToRepositories, sender: nil)
        
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
    
    func PARegisterControllerDidSuccessfullySignInUser(user: FIRUser) {
        
        //  First dismiss the register view controller that is being presented
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        //  If the registration/login was successful then we can load the data
        //  on the home page
        self.loadData()
    }
    
    func PARegisterControllerCouldNotSignInUser() {
        
        print("\nI could not sign in the user!")
    }
}
extension PAHomeViewController : PADataManagerDelegate {
    internal func PADataManagerDidFinishUploadingStory(storyID: String) {
        
    }

    
    func PADataMangerDidConfigure() {
        //  I don't think there needs to be any implementation here
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
