//
//  loginScreen.swift
//  SpriteKitGameMM
//
//  Created by Ryan  Gunn on 2/15/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import UIKit
import Parse

class LoginScreen: UIViewController{

    @IBOutlet var userNameTextField: UITextField!

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func loginButton(sender: UIButton) {
        var usrEntered = userNameTextField.text
        var pwdEntered = passwordTextField.text
        var emlEntered = emailTextField.text
        userSignUp()


    }

    func userSignUp() {
        var usrEntered = userNameTextField.text
        var pwdEntered = passwordTextField.text
        var emlEntered = emailTextField.text

        var user = PFUser()
        user.username = usrEntered
        user.password = pwdEntered
        user.email = emlEntered

        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                // Hooray! Let them use the app now.
                //self.messageLabel.text = "User Signed Up";
                println("\(user)")
            } else {
                println("error")
                // Show the errorString somewhere and let the user try again.
            }
        }

    }






}