//
//  GameScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var increment = 0
    var soldierNode:Soldier?


    let buttonJump = SKSpriteNode(imageNamed: "directionUpRed")
    let buttonDuck = SKSpriteNode(imageNamed: "directionDownRed")
    let buttonFire = SKSpriteNode(imageNamed: "fireButtonRed")
    let healthStatus = SKSpriteNode(imageNamed: "healthStatus")
    let scoreKeeperBG = SKSpriteNode(imageNamed: "scoreKeeperBG")


    override func didMoveToView(view: SKView) {


//        self.physicsWorld.gravity = CGVectorMake(0.0, -2)




        var groundInfo:[String: String] = ["ImageName": "groundOutside",
                                            "BodyType": "square",
                                            "Location": "{0, 100}",
                                   "PlaceMultiplesOnX": "10",]

        let groundPlatform = Object(groundDict: groundInfo)
        addChild(groundPlatform)


        soldierNode = Soldier(imageNamed: "Idle__000")
        soldierNode?.position = CGPointMake(300, 300)
        soldierNode?.setScale(0.65)
        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Idle)
        soldierNode?.stepState()


        // PUT THIS STUFF INTO A SEPERATE GAME BUTTON CONTROLLERS CLASS

        buttonJump.position = CGPointMake(75, 400)
        buttonJump.setScale(1.6)
        addChild(buttonJump)

        buttonDuck.position = CGPointMake(75, 200)
        buttonDuck.setScale(1.6)
        addChild(buttonDuck)

        buttonFire.position = CGPointMake(75, 300)
        buttonFire.setScale(1.4)
        addChild(buttonFire)

        healthStatus.position = CGPointMake(100, 630)
        healthStatus.setScale(1.1)
        addChild(healthStatus)

        scoreKeeperBG.position = CGPointMake(910, 630)
        scoreKeeperBG.setScale(1.0)
        addChild(scoreKeeperBG)

    }


    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//         Called when a touch begins 

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)

            soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
            soldierNode?.stepState()

            if CGRectContainsPoint(buttonJump.frame, location ) {
                jump()
            } else if CGRectContainsPoint(buttonDuck.frame, location) {
                duck()

            } else if CGRectContainsPoint(buttonFire.frame, location) {
                walkShoot()
            } else {
                run()
            }

        }
    }

    func jump() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Jump)
        soldierNode?.stepState()
    }

    func duck() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Crouch)
        soldierNode?.stepState()
    }

    func run() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run)
        soldierNode?.stepState()
    }

    func runShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.RunShoot)
        soldierNode?.stepState()
    }

    func walkShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.WalkShoot)
        soldierNode?.stepState()
    }

    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead)
        soldierNode?.stepState()
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        soldierNode?.update()
    }
}











