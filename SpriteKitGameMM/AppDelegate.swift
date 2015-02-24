//
//  AppDelegate.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import UIKit
import Parse
import Fabric
import Crashlytics
import AudioToolbox.AudioServices
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow?
    var bgMusicPlayer = AVAudioPlayer()
    var inGameMusicPlayer = AVAudioPlayer()
    var isMuted:Bool?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics()])

        Parse.setApplicationId("PeaTcxDstCFxbD320OshP9bA9PkBXvyNIw5FJlIF", clientKey: "fU0X9yNe0TUmr566CoSU0gVmnjzBRQUZcJzCTUft")
        FBLoginView.self
        FBProfilePictureView.self
        PFFacebookUtils.initializeFacebook()

        isMuted = false

        var bgMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ThemeOfKingsSnippet", ofType: "mp3")!)
        bgMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusic, error: nil)
        bgMusicPlayer.delegate = self
        bgMusicPlayer.numberOfLoops = -1
        bgMusicPlayer.play()
        var inGameMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ConquerIt", ofType: "mp3")!)
        inGameMusicPlayer = AVAudioPlayer(contentsOfURL: inGameMusic, error: nil)


        return true
    }

    func startBGMusic() {
        bgMusicPlayer.play()
    }

    func startInGameMusic() {
        inGameMusicPlayer.play()
    }

    func stopInGameMusic() {
        inGameMusicPlayer.stop()
    }

    func stopBGMusic() {
        bgMusicPlayer.stop()
    }

    func stopAllMusic() {
        stopBGMusic()
        stopInGameMusic()
        isMuted = true
    }


    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString?, annotation: AnyObject) -> Bool {

        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        return wasHandled
        
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

         NSNotificationCenter.defaultCenter().postNotificationName("stayPausedNotification", object:nil)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

         NSNotificationCenter.defaultCenter().postNotificationName("stayPausedNotification", object:nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

