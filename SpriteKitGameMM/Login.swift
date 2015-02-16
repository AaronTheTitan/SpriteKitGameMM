//
//  Login.swift
//  SpriteKitGameMM
//
//  Created by Ryan  Gunn on 2/16/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import UIKit
import Parse


class Login: UIViewController{

    @IBOutlet var userNameTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


    @IBAction func loginButtonPressed(sender: UIButton) {

        userLogin()
    }


    func userLogin() {
        var usrEntered = userNameTextField.text
        var pwdEntered = passwordTextField.text


        var user = PFUser()
        user.username = usrEntered
        user.password = pwdEntered


        PFUser.logInWithUsernameInBackground(usrEntered, password: pwdEntered) {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                println("\(user)")
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                var alert = UIAlertController(title: "Invalid Login", message: "Username or password is incorret", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                // The login failed. Check error to see why.
            }
        }
        
    }


}

