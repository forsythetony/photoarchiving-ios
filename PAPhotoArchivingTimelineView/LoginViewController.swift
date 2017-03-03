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
    func PALoginViewControllerUserDidClickSignUp()
}

class LoginViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    
    @IBOutlet weak var emailTextboxUnderline: UIView!
    
    @IBOutlet weak var passwordTextboxUnderline: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    
    
    var delegate : PALoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _setup()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
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
        
        //  If the user wants to register then we need to inform the presenting
        //  view controller about this so that it can dismiss this view controller
        //  and present the sign in view controller.
        self.delegate?.PALoginViewControllerUserDidClickSignUp()
        
    }

    func _setup() {
        
        //  Navigation Bar
        self.navigationController?.navigationBar.barTintColor = Color.MainApplicationColor
        self.navigationController?.navigationBar.isTranslucent = false
        
        //  Set up the colors for the text fields
        let titleLabelColor             = UIColor.white
        let textfieldTextColor          = UIColor.white
        let textfieldPlaceholderColor   = Color.PAWhiteTwo
        let buttonTextColor             = UIColor.white
        let underlineColor              = UIColor.white
        
        
        emailTitleLabel.textColor       = titleLabelColor
        emailTitleLabel.font            = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: emailTitleLabel.font.pointSize)
        
        passwordTitleLabel.textColor    = titleLabelColor
        passwordTitleLabel.font         = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: passwordTitleLabel.font.pointSize)
        
        userEmailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor ])
        userPasswordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor])
        
        userEmailTextField.textColor    = textfieldTextColor
        userPasswordTextField.textColor = textfieldTextColor
        
        loginButton.setTitleColor(buttonTextColor, for: .normal)
        registerButton.setTitleColor(buttonTextColor, for: .normal)
        
        passwordTextboxUnderline.backgroundColor    = underlineColor
        emailTextboxUnderline.backgroundColor       = underlineColor
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
