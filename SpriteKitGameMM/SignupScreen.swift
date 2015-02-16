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

class SignupScreen: UIViewController{

    @IBOutlet var userNameTextField: UITextField!



    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.fbLoginView.delegate = self
//        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]

    }

   
    @IBAction func facebookButtonPress(sender: UIButton) {

        facebookSignIn()


    }

    func facebookSignIn() {
        let permissions = ["public_profile", "email", "user_friends"]

        PFFacebookUtils.logInWithPermissions(permissions, {
            (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
            } else {
                NSLog("User logged in through Facebook!")
            }
        })
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