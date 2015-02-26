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
    class func unarchiveFromFileTutorial(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)

            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as TutorialScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = TutorialScene.unarchiveFromFileTutorial("TutorialScene") as? TutorialScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = false
            skView.showsNodeCount = false

            NSNotificationCenter.defaultCenter().addObserverForName("mainMenu", object: nil, queue: nil) { (notification: NSNotification?) in

                self.performSegueWithIdentifier("mainMenuSegue", sender: self)
                scene.removeAllChildren()
                scene.removeAllActions()


                return
            }


            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)


            scene.currentSoldier = NSUserDefaults.standardUserDefaults().objectForKey("currentSoldierString") as? String

        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false);


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
}
