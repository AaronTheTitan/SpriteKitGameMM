//
//  GameViewController.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import UIKit
import SpriteKit


extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, UIAlertViewDelegate {

    var currentSoldier:String?
    var alert:UIAlertController!
    var highScoreTextField:UITextField?
    let nameTextField:UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true

            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)

//            scene.currentSoldier = self.currentSoldier!
            scene.currentSoldier = NSUserDefaults.standardUserDefaults().objectForKey("currentSoldierString") as? String


            NSNotificationCenter.defaultCenter().addObserverForName("segue", object: nil, queue: nil) { (notification: NSNotification?) in

                self.performSegueWithIdentifier("gameOverSegue", sender: self)
                scene.removeAllChildren()
                scene.removeAllActions()

                return
            }

//            NSNotificationCenter.defaultCenter().addObserverForName("pause", object: nil, queue: nil) { (notification: NSNotification?) in
//
//                self.performSegueWithIdentifier("pauseSegue", sender: self)
//
//
//                return
//            }



            NSNotificationCenter.defaultCenter().addObserverForName("leader", object: nil, queue: nil) { (notification: NSNotification?) in
                self.performSegueWithIdentifier("leaderSegue", sender: self)
                
                scene.removeAllChildren()
                scene.removeAllActions()
                //scene.scoreInfo.score
                //println("\(scene.scoreInfo.score)")

                return
            }


            NSNotificationCenter.defaultCenter().addObserverForName("highscore", object: nil, queue: nil) { (notification: NSNotification?) in


                let alertController = UIAlertController(title: "New High Score", message: "Enter your name and post your new high score.", preferredStyle: .Alert)

                               let postAction = UIAlertAction(title: "Post", style: .Default) { (action) in
                    let name = alertController.textFields![0] as UITextField

                    var gameScore = PFObject(className: "GameScore")
                    gameScore.setObject(NSUserDefaults.standardUserDefaults().integerForKey("highscore"), forKey: "score")
                    gameScore.setObject(name.text, forKey: "playerName")
                    gameScore.saveInBackgroundWithBlock {
                        (success: Bool!, error: NSError!) -> Void in
                        if (success != nil) {

                            //NSLog("Object created with id: \(gameScore.objectId)")
                        } else {
                            NSLog("%@", error)
                        }
                        
                    }
                     self.performSegueWithIdentifier("leaderSegue", sender: self)
                }
                alertController.addAction(postAction)

                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
                alertController.addTextFieldWithConfigurationHandler { (textField) in
                    textField.placeholder = "Name"
                    textField.keyboardType = .EmailAddress
                }


                return
            }

        }
    }




    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        
    }
}
