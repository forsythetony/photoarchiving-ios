//
//  LoginViewController.swift
//  UserLoginAndRegisttation
//
//  Created by YUNFEI YANG on 2/9/17.
//  Copyright © 2017 YUNFEI YANG. All rights reserved.
//

import UIKit

protocol PALoginViewControllerDelegate {
    func PALoginViewControllerDidSignInSuccessfully()
}

class LoginViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    var delegate : PALoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        
        _ = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        _ = UserDefaults.standard.string(forKey: "userEmail")
        let userPasswordStored = UserDefaults.standard.string(forKey: "userPassword")
        if(userPasswordStored == userPassword)
        {
            if (userPasswordStored == userPassword)
            {
                //Login is successfull
                UserDefaults.standard.set(true,forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                
                //  Alert your delegate that you did sign in successfully
                self.delegate?.PALoginViewControllerDidSignInSuccessfully()
            }
        }
        
        
    }
    
    @IBAction func didTapRegister(_ sender: Any) {
        
        //  If the user wants to register then present the registration
        //  view controller modally.
        self.performSegue(withIdentifier: Constants.SegueIDs.SegueFromSignInToRegisterPage, sender: nil)
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
