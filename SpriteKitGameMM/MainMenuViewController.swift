//
//  MainMenuViewController.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/22/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import AudioToolbox.AudioServices
import AVFoundation

class MainMenuViewController: UIViewController {

    var savedSoldier = NSUserDefaults.standardUserDefaults()
//    var soundBGMusic = SKAction.playSoundFileNamed("ThemeOfKingsSnippet.mp3", waitForCompletion: true)


    //    let soldierImages:[UIImage] = [UIImage(named: "Idle__007")!, UIImage(named: "G-Idle__007")!]

    @IBOutlet var imageViewSoldier: UIImageView!

//    let soldierOneString:String = "Idle__007"
//    let soldierTwoString:String = "G-Idle__007"


    let soldierImages:[String] = ["S1-Idle__007" , "S2-Idle__007", "S3-Idle__007", "S4-Idle__007"]
    let soldierOrder:[String] = ["S1", "S2", "S3", "S4"]
    var soldierImageIndex:Int = 0

    override func viewWillAppear(animated: Bool) {
        if savedSoldier.objectForKey("currentSoldier") != nil {
            imageViewSoldier.image = UIImage(named: savedSoldier.objectForKey("currentSoldier") as String)
        }

//        self.runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("ThemeOfKingsSnippet.mp3", waitForCompletion: true)))



    }


    @IBAction func buttonTapChangeSoldier(sender: UIButton) {

        soldierImageIndex++

        let selectedSoldier = soldierCycle()
        savedSoldier.setObject(selectedSoldier, forKey: "currentSoldier")
        savedSoldier.synchronize()

        savedSoldier.setObject(self.soldierOrder[soldierImageIndex], forKey: "currentSoldierString")

        imageViewSoldier.image = UIImage(named: savedSoldier.objectForKey("currentSoldier") as String)


    }


    func soldierCycle() -> String {

        if soldierImageIndex >= soldierImages.count {
            soldierImageIndex = 0
        }

        return soldierImages[soldierImageIndex]

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if let gameViewController = segue.destinationViewController as? GameViewController
        {
            gameViewController.currentSoldier = NSUserDefaults.standardUserDefaults().objectForKey("currentSoldierString") as? String
    }

    }

}