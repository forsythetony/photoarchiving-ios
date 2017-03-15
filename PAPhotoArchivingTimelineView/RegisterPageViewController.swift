//
//  RegisterPageViewController.swift
//  UserLoginAndRegisttation
//
//  Created by YUNFEI YANG on 2/9/17.
//  Copyright © 2017 YUNFEI YANG. All rights reserved.
//

import UIKit

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
    
    
    
    
    let dataMan : PADataManager = PADataManager.sharedInstance
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let userEmail = userEmailTextField.text
        let userPassword = userPasswordTextField.text
        let userRepeatPassword = repeatPasswordTextField.text
        
        //check for empty field
        if (userEmail=="" && userPassword=="" && userRepeatPassword=="")
        {
            //display alert message
            displayMyAlertMessage(userMessage: "All field are required")
            return
            
        }
        
        //check if password match
        if (userPassword != userRepeatPassword )
        {
            //display alert messsage
            displayMyAlertMessage(userMessage: "Password does not match")
            return;
            
        }
        
        //store data
        UserDefaults.standard.set(userEmail,forKey:"userEmail")
        UserDefaults.standard.set(userEmail,forKey:"userPassword")
        UserDefaults.standard.synchronize()
        
        
        
        //Display alert message with confirmation
        /*var MyAlert =  UIAlertController(title:"Alert", message:"Registeration is sucessful!", preferredStyle:UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default)
        {
            action in self.dismiss(animated: true,completion: nil)
        }
        myAlert.addAction(okAction)
        self.presentedViewController（myAlert, animated:true, completion:nil）
        */
        
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
        
        passwordUnderlineView.backgroundColor = underlineColor
        
        
        /*
            Repeat Password Text Field Settings
        */
        repeatPasswordTitleLabel.textColor = titleLabelsTextColor
        repeatPasswordTitleLabel.font = UIFont(name: Constants.Fonts.MainFontFamilies.bold, size: repeatPasswordTitleLabel.font.pointSize)
        
        repeatPasswordTextField.textColor = textfieldTextColor
        repeatPasswordTextField.attributedPlaceholder = NSAttributedString(string: "repeat password", attributes: [ NSForegroundColorAttributeName : textfieldPlaceholderColor ])
        
        repeatPasswordUnderlineView.backgroundColor = underlineColor
    }
    
    
    
    
    
    func displayMyAlertMessage(userMessage:String)
    {
        /*var MyAlert =  UIAlertController(title:"Alert", message:userMessage, preferredStyle:UIAlertControllerStyle.alert)
        let okAction = UIAlertController(title:"Ok" , message:UIAlertActionStyle.Default, preferredStyle:nil)
        MyAlert.addAction(okAction)
        */
        
    }
    

}
