// Playground - noun: a place where people can play

import UIKit
import SpriteKit


var score = 15

NSUserDefaults.standardUserDefaults().integerForKey("highscore")

//Check if score is higher than NSUserDefaults stored value and change NSUserDefaults stored value if it's true
if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
    NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
    NSUserDefaults.standardUserDefaults().synchronize()
}

NSUserDefaults.standardUserDefaults().integerForKey("highscore")

