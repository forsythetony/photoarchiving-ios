//
//  LoginViewController.swift
//  UserLoginAndRegisttation
//
//  Created by YUNFEI YANG on 2/9/17.
//  Copyright © 2017 YUNFEI YANG. All rights reserved.
//

import UIKit
import FirebaseAuth
import SCLAlertView

protocol PALoginViewControllerDelegate {
    func PALoginViewControllerDidSignInSuccessfully()
    func PALoginViewControllerUserDidClickSignUp()
}

//fileprivate struct TextboxTags {
//    static let username = 0
//    static let password = 1
//}
class LoginViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    
    @IBOutlet weak var emailTextboxUnderline: UIView!
    
    @IBOutlet weak var passwordTextboxUnderline: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    
    let dataMan = PADataManager.sharedInstance
    
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
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        self.loginUser()
    }
    
 
    @IBAction func didTapRegister(_ sender: Any) {
        //  If the user wants to register then we need to inform the presenting
        //  view controller about this so that it can dismiss this view controller
        //  and present the sign in view controller.
        self.delegate?.PALoginViewControllerUserDidClickSignUp()
        
    }
    
    fileprivate func loginUser() {
        guard let userEmail = userEmailTextField.text else {
            print("There was not a valid user email")
            return
        }
        
        guard let userPassword = userPasswordTextField.text else {
            print("There was not a valid user password")
            return
        }
        
        self.dataMan.signInUserWithCredentials(username: userEmail, password: userPassword)
    }
    func _setup() {
        
        self.dataMan.delegate = self
        
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
        userEmailTextField.spellCheckingType = .no
        userEmailTextField.autocorrectionType = .no
        
        userPasswordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor])
        userPasswordTextField.spellCheckingType = .no
        userPasswordTextField.spellCheckingType = .no
        
        userPasswordTextField.delegate = self
        userEmailTextField.delegate = self
        
        userEmailTextField.textColor    = textfieldTextColor
        userPasswordTextField.textColor = textfieldTextColor
        userPasswordTextField.isSecureTextEntry = true
        
        
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

extension LoginViewController : PADataManagerDelegate {
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
        
    }
    
    func PADataManagerDidGetNewRepository(_ newRepository: PARepository) {
        
    }
    
    func PADataManagerDidSignInUserWithStatus(_ signInStatus: PAUserSignInStatus) {
        
        guard signInStatus != .SignInFailed else {
            
            SCLAlertView().showError("Error Signing In", subTitle: "There was an error signing in")
            return
        }
        
        
       self.delegate?.PALoginViewControllerDidSignInSuccessfully()
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.userEmailTextField {
            self.userPasswordTextField.becomeFirstResponder()
        }
        else if textField == self.userPasswordTextField {
            self.userPasswordTextField.resignFirstResponder()
            self.loginUser()
        }
        
        return false
    }
}
