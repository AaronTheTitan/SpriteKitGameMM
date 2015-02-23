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




class LeaderBoard: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

   var score:Int?
    var highScoreArray = [Int]()
    var nameArray = [String]()

    @IBOutlet var postButton: UIButton!

    @IBOutlet var nameTextField: UITextField!

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        //NSInteger score = [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
        postButton.hidden = true
        nameTextField.hidden = true

        score  = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        
        println("\(score!)")
        //tableView.registerNib(UINib(nibName: "LeaderBoardCell", bundle: nil), forCellReuseIdentifier: "leaderBoardCell")

        tableView.backgroundColor = UIColor.blackColor()

        addHighScoreObject()


        self.nameTextField.delegate = self
}



    func addHighScoreObject () {
        var playerNameArray = [String]()
        var scoreArray = [Int]()
        var query = PFQuery(className:"GameScore")
        query.orderByAscending("score")
        //query.whereKey("playerName", equalTo:"Sean Plott")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                //NSLog("Successfully retrieved \(objects.count) scores.")
                // Do something with the found objects

                for object in objects {
                    var playerName = object.objectForKey("playerName") as String
                    var score = object.objectForKey("score") as Int

                    playerNameArray.insert(playerName, atIndex: 0)
                    scoreArray.insert(score, atIndex: 0)

                    self.highScoreArray = scoreArray
                    self.nameArray = playerNameArray
                    //println("\(self.nameArray)")


                }

                self.tableView.reloadData()

            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
            }
            
        }

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameArray.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let color = Color(rawValue: indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("leaderBoardCell") as UITableViewCell
        cell.backgroundColor = UIColor.grayColor()


        if !nameArray.isEmpty{
        //println(" These are the player \(self.nameArray)")

        var nameString = self.nameArray[indexPath.row]
        cell.textLabel!.text = "\(indexPath.row + 1). \(nameString)"

            var scoreString = self.highScoreArray[indexPath.row]
            cell.detailTextLabel?.text = "\(scoreString) points"
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        }
        return cell
    }


    func postGameScore () {
        var gameScore = PFObject(className: "GameScore")
        gameScore.setObject(NSUserDefaults.standardUserDefaults().integerForKey("highscore"), forKey: "score")
        gameScore.setObject(nameTextField.text, forKey: "playerName")
        gameScore.saveInBackgroundWithBlock {
            (success: Bool!, error: NSError!) -> Void in
            if (success != nil) {
                self.tableView.reloadData()
                //NSLog("Object created with id: \(gameScore.objectId)")
            } else {
                NSLog("%@", error)
            }

        }

    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func postToLeaderBoardButtonPressed(sender: UIButton) {
        postButton.hidden = false
        nameTextField.hidden = false
        nameTextField.becomeFirstResponder()
    }

    @IBAction func postButtonPressed(sender: UIButton) {
       postGameScore()
        nameTextField.resignFirstResponder() == true
        self.tableView.reloadData()

    }

    @IBAction func faceBookButtonPressed(sender: UIButton) {

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("My high score on Bomb Rush is \(score!), try to beat that")
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
            twitterSheet.setInitialText("My high score on Bomb Rush is \(score!), try to beat that")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }


    }


}