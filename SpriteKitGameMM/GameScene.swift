//
//  GameScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {

   // var increment = 0
    var soldierNode:Soldier?
    var obstruction:Obstruction!
    struct PhysicsCategory {
        static let None              : UInt32 = 0
        static let SoldierCategory   : UInt32 = 0b1       // 1
        static let ObstacleCategory  : UInt32 = 0b10      // 2
        static let Edge              : UInt32 = 0b100     // 3
        static let ObstructionCategory : UInt32 = 0b1000  // 4
    }
//    let buttonJump:ControllerButton?
//    let buttonDuck:ControllerButton?

    let buttonJump = SKSpriteNode(imageNamed: "directionUpRed")
    let buttonDuck = SKSpriteNode(imageNamed: "directionDownRed")


    override func didMoveToView(view: SKView) {

        let edge = SKNode()
        edge.physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        edge.physicsBody!.usesPreciseCollisionDetection = true
        edge.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        edge.physicsBody!.dynamic = false
        addChild(edge)

        //added for collision detection
         self.physicsWorld.gravity = CGVectorMake(0, -4.5)

         physicsWorld.contactDelegate = self

         obstruction = Obstruction(imageNamed: "Spaceship")
         obstruction?.setScale(0.75)
         obstruction.physicsBody = SKPhysicsBody(circleOfRadius: obstruction!.size.width/2)
         obstruction.position = CGPointMake(240.0, 250.0)
         obstruction.physicsBody?.dynamic = false
         obstruction.physicsBody?.categoryBitMask = PhysicsCategory.ObstructionCategory
         obstruction.physicsBody?.collisionBitMask = PhysicsCategory.SoldierCategory
         obstruction.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
         obstruction.physicsBody?.usesPreciseCollisionDetection = true

         addChild(obstruction)

        soldierNode = Soldier(imageNamed: "Walk__000")
        //was 300, 300
        soldierNode?.position = CGPointMake(300, 450)
        soldierNode?.setScale(0.25)

        soldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: soldierNode!.size)
        soldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        soldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.usesPreciseCollisionDetection = true

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

    func soldierDidCollideWithObstacle(Soldier:SKSpriteNode, Obstruction:SKSpriteNode) {
       //soldierNode!.removeFromParent()
    }

    func didBeginContact(contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0)) {
                soldierDidCollideWithObstacle(firstBody.node as SKSpriteNode, Obstruction: secondBody.node as SKSpriteNode)
        }
        
    }

    func addSoldier(){
        soldierNode = Soldier(imageNamed: "Walk__000")
        //was 300, 300
        soldierNode?.position = CGPointMake(450, 450)
        soldierNode?.setScale(0.25)

        soldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: soldierNode!.size)
        soldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        soldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Idle)
        soldierNode?.stepState()
    }


    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//         Called when a touch begins 
        addSoldier()

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
            soldierNode?.stepState()

            if CGRectContainsPoint(buttonJump.frame, location ) {
                jump()
                let changeColorAction = SKAction.colorizeWithColor(SKColor.blueColor(), colorBlendFactor: 1.0, duration: 0.5)
                soldierNode!.runAction(changeColorAction)

            } else if CGRectContainsPoint(buttonDuck.frame, location) {
                duck()
                let changeColorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5)
                soldierNode!.runAction(changeColorAction)

            } else {
                run()
                soldierNode!.position = location
                let changeColorAction = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.5)
                soldierNode!.runAction(changeColorAction)
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











