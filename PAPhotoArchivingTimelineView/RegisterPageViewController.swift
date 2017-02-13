//
//  RegisterPageViewController.swift
//  UserLoginAndRegisttation
//
//  Created by YUNFEI YANG on 2/9/17.
//  Copyright © 2017 YUNFEI YANG. All rights reserved.
//

import UIKit

class RegisterPageViewController: UIViewController {
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    
    func displayMyAlertMessage(userMessage:String)
    {
        /*var MyAlert =  UIAlertController(title:"Alert", message:userMessage, preferredStyle:UIAlertControllerStyle.alert)
        let okAction = UIAlertController(title:"Ok" , message:UIAlertActionStyle.Default, preferredStyle:nil)
        MyAlert.addAction(okAction)
        */
        
    }
    

}
