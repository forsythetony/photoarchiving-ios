//
//  PAHomeViewController.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 2/13/17.
//  Copyright © 2017 Tony Forsythe. All rights reserved.
//

import UIKit

class PAHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkIfUserSignedIn()
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
            
            //  Here add the code to set the delegate of the destination view controller
            //  to this view controller
            let dest = segue.destination as! LoginViewController
            
            dest.delegate = self
            
        default:
            break
        }
        
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
