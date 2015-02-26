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

    @IBOutlet weak var muteButton: UIButton!
    var savedSoldier = NSUserDefaults.standardUserDefaults()
//    var soundBGMusic = SKAction.playSoundFileNamed("ThemeOfKingsSnippet.mp3", waitForCompletion: true)


    //    let soldierImages:[UIImage] = [UIImage(named: "Idle__007")!, UIImage(named: "G-Idle__007")!]

    var audioPlayer = AVAudioPlayer()
//    var bgMusicPlayer = AVAudioPlayer()

    //var isMuted:Bool?
    @IBOutlet var imageViewSoldier: UIImageView!

//    let soldierOneString:String = "Idle__007"
//    let soldierTwoString:String = "G-Idle__007"


    let soldierImages:[String] = ["S1-Idle__007" , "S2-Idle__007", "S3-Idle__007", "S4-Idle__007"]
    let soldierOrder:[String] = ["S1", "S2", "S3", "S4"]
    var soldierImageIndex:Int = 0

    override func viewWillAppear(animated: Bool) {
        if savedSoldier.objectForKey("currentSoldier") != nil {
            imageViewSoldier.image = UIImage(named: savedSoldier.objectForKey("currentSoldier") as String)

        } else {
        savedSoldier.setObject(self.soldierOrder[soldierImageIndex], forKey: "currentSoldierString")
        savedSoldier.synchronize()

        }

        var selectionSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("SwitchSoldier", ofType: "mp3")!)
        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)

        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: selectionSound, error: &error)
        audioPlayer.prepareToPlay()

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        if appDelegate.isMuted == false {
            appDelegate.stopInGameMusic()
            appDelegate.startBGMusic()
            muteButton.setTitle("Mute", forState: nil)
        } else {
            muteButton.setTitle("Unmute", forState: nil)

        }
    }


    @IBAction func onMuteButtonTapped(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        if appDelegate.isMuted == true {
            appDelegate.isMuted = false
//            muteButton.setTitle("Mute", forState: nil)
//            sender.imageView?.image = UIImage(named: "muteButtonBlue")
            sender.backgroundImageForState(UIControlState.Normal)

            appDelegate.stopInGameMusic()
            appDelegate.startBGMusic()
        } else {
            appDelegate.isMuted = true
//            muteButton.setTitle("Unmute", forState: nil)
//            sender.imageView?.image = UIImage(named: "muteButtonGray")
            sender.backgroundImageForState(UIControlState.Selected)
//            sender.setAttributedTitle("backgroundImageForState", forState: "")
            appDelegate.stopAllMusic()
//            appDelegate.stopInGameMusic()
//            appDelegate.stopBGMusic()
//            
        }
    }
//    func playBGMusic() {
//
//        var bgMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ThemeOfKingsSnippet", ofType: "mp3")!)
//        bgMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusic, error: nil)
//
//        if bgMusicPlayer.playing == false {
//            bgMusicPlayer.prepareToPlay()
//            bgMusicPlayer.play()
//            bgMusicPlayer.playing == true
//        }
//
//    }


    @IBAction func buttonTapChangeSoldier(sender: UIButton) {

        soldierImageIndex++
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let selectedSoldier = soldierCycle()
        savedSoldier.setObject(selectedSoldier, forKey: "currentSoldier")
        savedSoldier.synchronize()

        savedSoldier.setObject(self.soldierOrder[soldierImageIndex], forKey: "currentSoldierString")

        imageViewSoldier.image = UIImage(named: savedSoldier.objectForKey("currentSoldier") as String)
        if appDelegate.isMuted == false {
        audioPlayer.play()

        }
//        audioPlayer.numberOfLoops = 1
//        audioPlayer.play()

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
            NSUserDefaults.standardUserDefaults().synchronize()

        }
    }

}