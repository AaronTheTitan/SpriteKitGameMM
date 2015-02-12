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

//    let buttonJump:ControllerButton?
//    let buttonDuck:ControllerButton?


    let buttonJump = SKSpriteNode(imageNamed: "directionUpRed")
    let buttonDuck = SKSpriteNode(imageNamed: "directionDownRed")




    override func didMoveToView(view: SKView) {

//        self.physicsWorld.gravity = CGVectorMake(0, -9.8)


        soldierNode = Soldier(imageNamed: "Walk__000")
        soldierNode?.position = CGPointMake(300, 300)
        soldierNode?.setScale(0.65)
        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Idle)
        soldierNode?.stepState()

        buttonJump.position = CGPointMake(75, 400)
        buttonJump.setScale(1.6)
        addChild(buttonJump)

        buttonDuck.position = CGPointMake(75, 200)
        buttonDuck.setScale(1.6)
        addChild(buttonDuck)

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

    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead)
        soldierNode?.stepState()
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */

        soldierNode?.update()




    }
}











