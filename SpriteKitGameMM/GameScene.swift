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
    var girlSoldierNode:GirlSoldier? // testing for adding another player for selection
    var obstruction:Obstruction!
    var max:Obstruction! // playing around
    var moveObject = SKAction()

    var bomb:Bomb!

    //allows us to differentiate sprites
    struct PhysicsCategory {
        static let None                : UInt32 = 0
        static let SoldierCategory     : UInt32 = 0b1     // 1
        static let ObstructionCategory : UInt32 = 0b10    // 2
        static let Edge                : UInt32 = 0b100   // 3
    }

    // Buttons
    let buttonJump    = SKSpriteNode(imageNamed: "directionUpRed")
    let buttonDuck    = SKSpriteNode(imageNamed: "directionDownRed")
    let buttonFire    = SKSpriteNode(imageNamed: "fireButtonRed")

    // Status Holders
    let healthStatus  = SKSpriteNode(imageNamed: "healthStatus")
    let scoreKeeperBG = SKSpriteNode(imageNamed: "scoreKeepYellow")

    let totalGroundPieces = 5
    var groundPieces = [SKSpriteNode]()

    let groundSpeed: CGFloat = 3.5
    var moveGroundAction: SKAction!
    var moveGroundForeverAction: SKAction!
    let groundResetXCoord: CGFloat = -500


    override func didMoveToView(view: SKView) {

        //added for collision detection
        //        view.showsPhysics = true
        initSetup()
        setupScenery()
        startGame()
         self.physicsWorld.gravity    = CGVectorMake(0, -4.5)
         physicsWorld.contactDelegate = self
//        var groundInfo:[String: String] = ["ImageName": "groundOutside",
//                                            "BodyType": "square",
//                                            "Location": "{0, 120}",
//                                   "PlaceMultiplesOnX": "10"
//                                                        ]
//
//        let groundPlatform = Object(groundDict: groundInfo)
//        addChild(groundPlatform)

        //addMax()
        //can comment out, need for reference for collisions
        //addDon()

        //adds soldier, moved to function to clean up
        addSoldier()
        addGirlSoldier()

        //add an edge to keep soldier from falling forever. This currently has the edge just off the screen, needs to be fixed.
        addEdge()

        // PUT THIS STUFF INTO A SEPERATE GAME BUTTON CONTROLLERS CLASS
        addButtons()

//        addBombs() // testing out bombs

        let distance = CGFloat(self.frame.size.width * 2.0)
        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.05 * distance))
        moveObject = SKAction.sequence([moveObstruction])

        let spawn = SKAction.runBlock({() in self.addBadGuys()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.9))
        let spawnThenDelay = SKAction.sequence([spawn,delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)

        self.runAction(spawnThenDelayForever)

    }
    //when Soldier collides with Obsturction, do this function (currently does nothing)
    func soldierDidCollideWithObstacle(Soldier:SKSpriteNode, Obstruction:SKSpriteNode) {
       //soldierNode!.removeFromParent()
    }

    //when contact begins
    func didBeginContact(contact: SKPhysicsContact) {

        var firstBody : SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody  = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody  = contact.bodyB
            secondBody = contact.bodyA
        }

        if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0)) {
                soldierDidCollideWithObstacle(firstBody.node as SKSpriteNode, Obstruction: secondBody.node as SKSpriteNode)
        }
    }

    func didEndContact(contact: SKPhysicsContact) {
        // will get called automatically when two objects end contact with each other
    }

    func initSetup()
    {
        moveGroundAction = SKAction.moveByX(-groundSpeed, y: 0, duration: 0.02)
        moveGroundForeverAction = SKAction.repeatActionForever(SKAction.sequence([moveGroundAction]))
    }

    func startGame()
    {
        for sprite in groundPieces
        {
            sprite.runAction(moveGroundForeverAction)
        }
    }

    func setupScenery()
    {
        /* Setup your scene here */

        //Add background sprites

        let bgImages:[String] = ["bg_spaceship_1", "bg_spaceship_2", "bg_spaceship_3"]

        var bg = SKSpriteNode(imageNamed: bgImages[0])

        bg.position = CGPointMake(bg.size.width / 2, bg.size.height / 2)

        self.addChild(bg)

        for var x = 0; x < bgImages.count; x++
        {
            var sprite = SKSpriteNode(imageNamed: bgImages[x])

             groundPieces.append(sprite)

            var wSpacing = sprite.size.width / 2
            var hSpacing = sprite.size.height / 2

            if x == 0
            {
                sprite.position = CGPointMake(wSpacing, hSpacing)
            }
            else
            {
                sprite.position = CGPointMake((wSpacing * 2) + groundPieces[x - 1].position.x,groundPieces[x - 1].position.y)
            }

            self.addChild(sprite)
        }
    }

    func groundMovement()
    {
        for var x = 0; x < groundPieces.count; x++
        {
            if groundPieces[x].position.x <= groundResetXCoord
            {
                if x != 0
                {
                    groundPieces[x].position = CGPointMake(groundPieces[x - 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                }
                else
                {
                    groundPieces[x].position = CGPointMake(groundPieces[x + 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
//                    groundPieces[x].position = CGPointMake(groundPieces[groundPieces.count - 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                }
            }
        }
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
                //can delete, just reference in case we want to change colors :)
                //let changeColorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5)
               //soldierNode!.runAction(changeColorAction)

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

        let delay = 0.07 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, dispatch_get_main_queue()) {
            self.girlSoldierNode?.setCurrentState(GirlSoldier.SoldierStates.Jump)
            self.girlSoldierNode?.stepState()
        }

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

    func walk() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
    }

    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead)
        soldierNode?.stepState()
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        soldierNode?.update()
        groundMovement()

    }

    //add a soldier, called in did move to view
    func addSoldier(){
        soldierNode = Soldier(imageNamed: "Walk__000")
        //was 300, 300
        soldierNode?.position = CGPointMake(450, 450)
        soldierNode?.setScale(0.45)
        soldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: soldierNode!.size)
        soldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        soldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        soldierNode?.physicsBody?.allowsRotation = false
        soldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
    }

    func addGirlSoldier() {
        girlSoldierNode = GirlSoldier(imageNamed: "G-Idle__000")
        girlSoldierNode?.position = CGPointMake(300, 450)
        girlSoldierNode?.setScale(0.45)
        girlSoldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: girlSoldierNode!.size)
        girlSoldierNode?.physicsBody?.allowsRotation = false
        girlSoldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        girlSoldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.ObstructionCategory
        girlSoldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory
        girlSoldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(girlSoldierNode!)

        girlSoldierNode?.setCurrentState(GirlSoldier.SoldierStates.Walk)
        girlSoldierNode?.stepState()

    }

    func addDon(){
        //Spaceship placeholder, don't delete. Can comment out
        obstruction = Obstruction(imageNamed: "don-bora")
        obstruction.setScale(0.45)
        obstruction.physicsBody = SKPhysicsBody(circleOfRadius: obstruction!.size.width/2)
       // obstruction.position = CGPointMake(740.0, 220.0)
//        let height = UInt32(self.frame.size.height / 4)
//        let y = arc4random() % height + height
        obstruction?.position = CGPointMake(1100.0, 175)

        obstruction.physicsBody?.dynamic = false
        obstruction.physicsBody?.categoryBitMask    = PhysicsCategory.ObstructionCategory
        obstruction.physicsBody?.collisionBitMask   = PhysicsCategory.SoldierCategory
        obstruction.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        obstruction.physicsBody?.usesPreciseCollisionDetection = true
        obstruction.runAction(moveObject)

        addChild(obstruction!)
    }

    // Having fun, can remove in real thang if we want
    func addMax(){

        max = Obstruction(imageNamed: "max-howell")
        max.setScale(0.45)
        max.physicsBody = SKPhysicsBody(circleOfRadius: max!.size.width/2)
       // max.position = CGPointMake(1020.0, 450)
        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random() % height + height
        max?.position = CGPointMake(1200.0, CGFloat(y + height))

        max.physicsBody?.dynamic = false
        max.physicsBody?.categoryBitMask = PhysicsCategory.ObstructionCategory
        max.physicsBody?.collisionBitMask = PhysicsCategory.SoldierCategory
        max.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        max.physicsBody?.usesPreciseCollisionDetection = true
        max.runAction(moveObject)

        addChild(max!)

    }

    func addBadGuys() {
        let distance = CGFloat(self.frame.size.width * 2.0)
        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.005 * distance))
        moveObject = SKAction.sequence([moveObstruction])

        //can comment out, need for reference for collisions
        let y = arc4random() % 2
        if y == 0 {
            addDon()
        } else if y == 1 {
            addMax ()
        } else {
            println(y)
        }
    }

 //add an edge to keep soldier from falling forever. This currently has the edge just off the screen, needs to be fixed.
    //add an edge to keep soldier from falling forever. This currently has the edge just off the screen, needs to be fixed.
        func addEdge() {
        let edge = SKNode()
        //might not need the minus 200...will see!
        edge.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0,y: 160,width: self.frame.size.width,height: self.frame.size.height-200))
        edge.physicsBody!.usesPreciseCollisionDetection = true
        edge.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        edge.physicsBody!.dynamic = false
        addChild(edge)
    }

    func addButtons(){
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

        scoreKeeperBG.position = CGPointMake(950, 610)
        scoreKeeperBG.setScale(1.3)
        addChild(scoreKeeperBG)
    }

//    func addBombs() {
//        bomb.position = CGPointMake(400, 450)
//        addChild(bomb)
//
//        bomb.bombAnimate()
//
//    }


}

