//
//  LeaderBoardViewController.swift
//  SpriteKitGameMM
//
//  Created by Ryan  Gunn on 2/21/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import Parse
import Social



class LeaderBoard: UIViewController{

 

    override func viewDidLoad() {
        super.viewDidLoad()

     


        NSNotificationCenter.defaultCenter().addObserverForName("leader", object: nil, queue: nil) { (notification: NSNotification?) in

            self.performSegueWithIdentifier("leaderSegue", sender: self)
            println("call me maybe")
            //scene.removeAllChildren()
            //scene.removeAllActions()

            return

        }


}


    @IBAction func faceBookButtonPressed(sender: UIButton) {

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Share on Facebook")
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }

    @IBAction func twitterButtonPressed(sender: UIButton) {

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }


    }


}