//
//  RegisterPageViewController.swift
//  UserLoginAndRegisttation
//
//  Created by YUNFEI YANG on 2/9/17.
//  Copyright © 2017 YUNFEI YANG. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol PARegisterControllerDelegate {
    func PARegisterControllerDidSuccessfullySignInUser( user : FIRUser )
    func PARegisterControllerCouldNotSignInUser()
}

class RegisterPageViewController: UIViewController {
    
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    
    @IBOutlet weak var repeatPasswordTitleLabel: UILabel!
    @IBOutlet weak var emailUnderlineView: UIView!
    
    @IBOutlet weak var passwordUnderlineView: UIView!
    @IBOutlet weak var repeatPasswordUnderlineView: UIView!
   
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    
    var delegate    : PARegisterControllerDelegate?
    
    let dataMan     : PADataManager = PADataManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        let userEmail           = userEmailTextField.text
        let userPassword        = userPasswordTextField.text
        let userRepeatPassword  = repeatPasswordTextField.text
        
        
        guard userEmail != nil, userPassword != nil, userRepeatPassword != nil else {
            let error_message = "One of the parameters was nil dude. Fix that shiz"
            self.displayMyAlertMessage(userMessage: error_message)
            return
        }
        
        
        if ( userEmail == "" || userPassword  == "" || userRepeatPassword == "" )
        {
            
            displayMyAlertMessage(userMessage: "All field are required")
            return
            
        }
        
        
        if (userPassword != userRepeatPassword )
        {
            
            displayMyAlertMessage(userMessage: "Password does not match")
            return
            
        }
        
        
        FIRAuth.auth()?.createUser(withEmail: userEmail!, password: userPassword!, completion: { (user, error) in
            
            if let error = error {
                let error_message = String.init(format: "There was an error creating the user -> %@", error.localizedDescription)
                self.displayMyAlertMessage(userMessage: error_message)
                
                self.delegate?.PARegisterControllerCouldNotSignInUser()
                
                return
            }
            
            if let user = user {
                
                let success_message = String.init(format: "Successfully created the user with credentials username=%@ and password=%@ and userID=%@", userEmail!, userPassword!, user.uid)
                self.displayMyAlertMessage(userMessage: success_message)
                
                self.delegate?.PARegisterControllerDidSuccessfullySignInUser(user: user)
                
                
                return
            }
            
            let error_message = "Something strange happened that I'm not quite equipped to handle!"
            self.displayMyAlertMessage(userMessage: error_message)
            
            self.delegate?.PARegisterControllerCouldNotSignInUser()
            
            return
        })
    }

    func _setup() {
        
        //  Configure the navigation bar
        self.navigationController?.navigationBar.barTintColor   = Color.MainApplicationColor
        self.navigationController?.navigationBar.isTranslucent  = false
        
        //  Set up the colors for the text fields
        let titleLabelsTextColor        = Color.PAWhiteOne
        let textfieldTextColor          = Color.PAWhiteOne
        let textfieldPlaceholderColor   = Color.PAWhiteOne
        let underlineColor              = Color.PAWhiteOne
        
        
        /*
            Title Text Label Settings
        */
        pageTitleLabel.textColor = titleLabelsTextColor
        pageTitleLabel.font         = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: pageTitleLabel.font.pointSize)
        
        /*
            Email Text Field Settings
        */
        emailTitleLabel.textColor = titleLabelsTextColor
        emailTitleLabel.font = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: emailTitleLabel.font.pointSize)
        
        userEmailTextField.textColor = textfieldTextColor
        userEmailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor ])
        
        emailUnderlineView.backgroundColor = underlineColor
        
        
        
        /*
            Password Text Field Settings
        */
        passwordTitleLabel.textColor = titleLabelsTextColor
        passwordTitleLabel.font = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: passwordTitleLabel.font.pointSize)
        
        userPasswordTextField.textColor = textfieldTextColor
        userPasswordTextField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor ] )
        userPasswordTextField.isSecureTextEntry = true
        
        passwordUnderlineView.backgroundColor = underlineColor
        
        
        /*
            Repeat Password Text Field Settings
        */
        repeatPasswordTitleLabel.textColor = titleLabelsTextColor
        repeatPasswordTitleLabel.font = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: repeatPasswordTitleLabel.font.pointSize)
        
        repeatPasswordTextField.textColor = textfieldTextColor
        repeatPasswordTextField.attributedPlaceholder = NSAttributedString(string: "repeat password", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor ])
        repeatPasswordTextField.isSecureTextEntry = true
        
        repeatPasswordUnderlineView.backgroundColor = underlineColor
    }
    
    
    
    
    
    func displayMyAlertMessage(userMessage:String)
    {
        let alert_message = String.init(format: "\n\nCaveman Alert Message!\n%@\n\n", userMessage )
        
        print(alert_message)
    }
    

}
