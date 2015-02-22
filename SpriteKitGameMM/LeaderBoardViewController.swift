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
import UIKit




class LeaderBoard: UIViewController, UITableViewDelegate, UITableViewDataSource{

   var score:Int?

    @IBOutlet var postButton: UIButton!

    @IBOutlet var nameTextField: UITextField!

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //NSInteger score = [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
        postButton.hidden = true
        nameTextField.hidden = true

        score  = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        
        println("\(score)")
        //tableView.registerNib(UINib(nibName: "LeaderBoardCell", bundle: nil), forCellReuseIdentifier: "leaderBoardCell")

        
}

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let color = Color(rawValue: indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("leaderBoardCell") as UITableViewCell

        //cell.textLabel!.text = color?.title()
        //cell.backgroundColor = color?.backgroundColor()


        return cell
    }


    func scoreArray () {
        var gameScore = PFObject(className: "GameScore")
        gameScore.setObject(NSUserDefaults.standardUserDefaults().integerForKey("highscore"), forKey: "score")
        gameScore.setObject(nameTextField.text, forKey: "playerName")
        gameScore.saveInBackgroundWithBlock {
            (success: Bool!, error: NSError!) -> Void in
            if (success != nil) {
                NSLog("Object created with id: \(gameScore.objectId)")
            } else {
                NSLog("%@", error)
            }
        }


    }


    @IBAction func postToLeaderBoardButtonPressed(sender: UIButton) {
        postButton.hidden = false
        nameTextField.hidden = false
    }

    @IBAction func postButtonPressed(sender: UIButton) {
        scoreArray()

    }

    @IBAction func faceBookButtonPressed(sender: UIButton) {

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("My high score on Bomb Rush is \(score), try to beat that")
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
            twitterSheet.setInitialText("My high score on Bomb Rush is \(score), try to beat that")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }


    }


}