//
//  MainMenuViewController.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/22/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import UIKit

class MainMenuViewController: UIViewController {

    //    let soldierImages:[UIImage] = [UIImage(named: "Idle__007")!, UIImage(named: "G-Idle__007")!]

    @IBOutlet var imageViewSoldier: UIImageView!

//    let soldierOneString:String = "Idle__007"
//    let soldierTwoString:String = "G-Idle__007"


    let soldierImages:[String] = ["S1-Idle__007" , "S2-Idle__007", "S3-Idle__007", "S4-Idle__007"]
    var soldierImageIndex:Int = 0


    @IBAction func buttonTapChangeSoldier(sender: UIButton) {
        
        soldierImageIndex++
        imageViewSoldier.image = UIImage(named: soldierCycle())
    }


    func soldierCycle() -> String {

        if soldierImageIndex >= soldierImages.count {
            soldierImageIndex = 0
        }

        return soldierImages[soldierImageIndex]

//        while soldierImageIndex < soldierImages.count {
//
//            var currentIndex = soldierImageIndex
////            soldierImageIndex++
//
//            if soldierImageIndex >= soldierImages.count {
//                soldierImageIndex = 0
//            }
//
//            return soldierImages[currentIndex]
//        }
//
//        return soldierImages[0]
    }





}