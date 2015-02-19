//
//  GameScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//
import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {
//----- BEGIN DECLARATIONS -----//

    // MARK: - PROPERTIES
    var gameWorld:SKNode?

    var soldierNode:Soldier?
    var obstruction:Obstruction!
    var warhead:Obstruction!
    var powerup: PowerUp?
    var powerupWhite: PowerUp?
    var bomb:Bomb?
    var bombExplode:Bomb?
    var warheadExplode:Bomb?

    var isRunning:Bool?

    var spriteposition:CGFloat  = 5
    var moveGroundForeverAction: SKAction!

    let world = WorldGenerator()

    var scoreInfo = ScoreLabel()

    //MARK: - AUDIO
    var soundPowerUp = SKAction.playSoundFileNamed("PowerUpOne.mp3", waitForCompletion: false)
    var soundSuperPowerUp = SKAction.playSoundFileNamed("PowerUpTwo.mp3", waitForCompletion: false)
    var soundJump = SKAction.playSoundFileNamed("Jump.mp3", waitForCompletion: false)

    // MARK: - BUTTONS
    let buttonscencePause   = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let buttonscencePlay = UIButton.buttonWithType(UIButtonType.System) as  UIButton

    // MARK: - GROUND/WORLD
    var moveObject = SKAction()

    let totalGroundPieces = 5


//----- BEGIN LOGIC -----//

// MARK: - VIEW/SETUP
    override func didMoveToView(view: SKView) {

        world.setupScenery()
        addChild(world)

        createbutton()

        world.groundMovement()

        addSoldier()
        world.addEdge()


        scoreInfo.addScoring()
        scoreInfo.labelScore.position = CGPointMake(20 + scoreInfo.labelScore.frame.size.width/2, self.size.height - (120 + scoreInfo.labelScore.frame.size.height/2))
        scoreInfo.highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - (120 + scoreInfo.labelScore.frame.size.height/2))

        addChild(scoreInfo)

        isRunning = false

        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)

        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)

        let tapShoot:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTaps:"))
        tapShoot.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapShoot)

        self.physicsWorld.gravity    = CGVectorMake(0, -40)
        physicsWorld.contactDelegate = self

        // PUT THIS STUFF INTO A SEPERATE GAME BUTTON CONTROLLERS CLASS


        let distance = CGFloat(self.frame.size.width * 2.0)
        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.05 * distance))
        moveObject = SKAction.sequence([moveObstruction])

        let spawn = SKAction.runBlock({() in self.addBadGuys()})
        var delay = SKAction.waitForDuration(NSTimeInterval(2.36))

        var spawnThenDelay = SKAction.sequence([spawn,delay])
        var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }

    func handleSwipes(sender:UISwipeGestureRecognizer) {

        if sender.direction == .Up {
            jump()

        } else if sender.direction == .Down {
            duck()

        }
    }

    func handleTaps(sender:UITapGestureRecognizer) {

        if isRunning == false {
            walkShoot()

        } else {
            runShoot()
        }
    }


// MARK: - COLLISION FUNCTIONS
    func soldierDidCollideWithSuperPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){
        PowerUp.removeFromParent()
        scoreInfo.score = scoreInfo.score + 2
        scoreInfo.labelScore.text = "Score: \(scoreInfo.score)"

        playSound(soundSuperPowerUp)

        if scoreInfo.score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
            NSUserDefaults.standardUserDefaults().setInteger(scoreInfo.score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func soldierDidCollideWithBomb(soldier:SKSpriteNode, bomb:SKSpriteNode) {
        bomb.removeFromParent()
        bombExplode?.bombExplode(bombExplode!)
        die()
    }

    func soldierDidCollideWithWarhead(soldier:SKSpriteNode, bomb:SKSpriteNode) {
        warhead.removeFromParent()
        warheadExplode?.warHeadExplode(warheadExplode!)
        die()
    }

    //when contact begins
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody: SKPhysicsBody

        //die()

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody  = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody  = contact.bodyB
            secondBody = contact.bodyA
        }


        if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.SuperPowerCategory != 0)){
                 soldierDidCollideWithSuperPowerup(firstBody.node as SKSpriteNode, PowerUp: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.BombCategory != 0)){
                soldierDidCollideWithBomb(firstBody.node as SKSpriteNode, bomb: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.WarheadCategory != 0)){
                soldierDidCollideWithWarhead(firstBody.node as SKSpriteNode, bomb: secondBody.node as SKSpriteNode)
        }

    }


// MARK: - GROUND SPEED MANIPULATION

    func groundSpeedIncrease() {

        var wait = SKAction.waitForDuration(1)
        var run = SKAction.runBlock {
            //var speedUpAction = SKAction.speedTo(self.groundSpeed, duration: self.timeIncrement)

            if self.spriteposition  == 25 {
                self.run()
                self.isRunning = true
            }
        }

        moveGroundForeverAction = SKAction.repeatActionForever(SKAction.sequence([run,wait]))

        for sprite in world.groundPieces {
            sprite.runAction(moveGroundForeverAction)
        }
    }

// MARK: - TOUCHES BEGAN
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        for touch: AnyObject in touches {

            let location = touch.locationInNode(self)
//            soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
            soldierNode?.stepState()
             //println("moneyteam")

        }

    }

// MARK: - SOLDIER ACTIONS

    func createbutton() {

        buttonscencePause.frame = CGRectMake(6.25, 316.25, 67.5, 50)
        //button.backgroundColor = UIColor.greenColor()
        let buttonPauseImage = UIImage(named: "buttonPause")
        buttonscencePause.setBackgroundImage(buttonPauseImage, forState: UIControlState.Normal)
        //button.setTitle("Test Button", forState: UIControlState.Normal)
        buttonscencePause.addTarget(self, action: "pauseGame", forControlEvents: UIControlEvents.TouchUpInside)

        buttonscencePlay.frame = CGRectMake(6.25, 316.25, 67.5, 50)
        //button.backgroundColor = UIColor.greenColor()
        let buttonPlayImage = UIImage(named: "buttonPlay")
        buttonscencePlay.setBackgroundImage(buttonPlayImage, forState: UIControlState.Normal)
        //button.setTitle("Test Button", forState: UIControlState.Normal)
        buttonscencePlay.addTarget(self, action: "resumeGame", forControlEvents: UIControlEvents.TouchUpInside)



        scene?.view?.addSubview(buttonscencePause)
        scene?.view?.addSubview(buttonscencePlay)
        buttonscencePlay.hidden = true
    }

//    UIButton * startButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 60, 20)];
//    startButton.backgroundColor = [UIColor redColor];
//
//    [self.view addSubview:startButton];
    func pauseGame()
    {
        //scene.view?.paused = true // to pause the game
        scene?.view?.paused = true
        buttonscencePause.hidden = true
        buttonscencePlay.hidden = false


    }
    func resumeGame()
    {
        //scene.view?.paused = true // to pause the game
        scene?.view?.paused = false

        buttonscencePause.hidden = false
        buttonscencePlay.hidden = true
    }

    func jump() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Jump)
        soldierNode?.stepState()
        playSound(soundJump)
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
        fireGun()
    }

    func walkShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.WalkShoot)
        soldierNode?.stepState()
        fireGun()
    }

    func walk() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
    }


    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead)
        soldierNode?.stepState()
    }

    func fireGun() {
        var fireShot = Bullet(imageNamed: "emptyMuzzle")
        addChild(fireShot)
        fireShot.position = CGPointMake(soldierNode!.position.x + 132, soldierNode!.position.y)
        fireShot.shootFire(fireShot)
    }

    let originalHeroPoint = CGPointMake(450, 450)

//MARK: - UPDATE
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if soldierNode?.position.x < originalHeroPoint.x - 300 || soldierNode?.position.x > originalHeroPoint.x + 300 {
                resetSoldierPosition()
        }

        soldierNode?.update()
        world.groundMovement()
        groundSpeedIncrease()



        if spriteposition < 19 {
            spriteposition = spriteposition + 0.35
        }
        
        
        for sprite in world.groundPieces {
            sprite.position.x -= spriteposition
            //println("\(spriteposition)")
        }

    }

    func resetSoldierPosition() {
        soldierNode?.position.x = originalHeroPoint.x
    }

// MARK: - ADD ASSETS TO SCENE
    func addSoldier() {
        soldierNode = Soldier(imageNamed: "Walk__000")
        soldierNode?.position = CGPointMake(250, 450)
        soldierNode?.setScale(0.32)
        soldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: soldierNode!.size)
        soldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        soldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        soldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory | PhysicsCategory.SuperPowerCategory | PhysicsCategory.BombCategory | PhysicsCategory.WarheadCategory
        soldierNode?.physicsBody?.allowsRotation = false
        soldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
    }

    // Having fun, can remove in real thang if we want
    func addWarhead() {

        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random_uniform(height) % height

        warhead = Obstruction(imageNamed: "warhead")
        warhead.setScale(0.45)
        warhead.physicsBody = SKPhysicsBody(circleOfRadius: warhead!.size.width/2)
        warhead?.position = CGPointMake(1090.0, CGFloat(y + height + 75))
        warhead.physicsBody?.dynamic = false
        warhead.physicsBody?.categoryBitMask = PhysicsCategory.WarheadCategory
        warhead.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        warhead.physicsBody?.usesPreciseCollisionDetection = true
        warhead.runAction(moveObject)
        addChild(warhead!)

        var warheadRocket = Bomb(imageNamed: "emptyMuzzle")
        warheadRocket.position = CGPointMake(warhead.position.x + 120, warhead.position.y)
        warheadRocket.rocketFire(warheadRocket)
        warheadRocket.runAction(moveObject)
        addChild(warheadRocket)

        warheadExplode = Bomb(imageNamed: "empty")
        warheadExplode?.setScale(0.6)
        warheadExplode?.position = CGPointMake(warhead!.position.x, warhead!.position.y + 100)
        warheadExplode?.runAction(moveObject)

        addChild(warheadExplode!)
    }

    func addPowerup() {
        powerup = PowerUp(imageNamed: "powerup")
        powerup?.setScale(0.85)
        powerup?.physicsBody = SKPhysicsBody(circleOfRadius: powerup!.size.width/200)
        powerup?.position = CGPointMake(1480.0, 620)
        powerup?.physicsBody?.dynamic = false
        powerup?.physicsBody?.categoryBitMask = PhysicsCategory.SuperPowerCategory
        powerup?.physicsBody?.collisionBitMask = PhysicsCategory.None
        powerup?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        powerup?.physicsBody?.usesPreciseCollisionDetection = true
        powerup?.runAction(moveObject)
        powerup?.powerUpBlue()

        addChild(powerup!)
    }

    func addPowerUpWhite() {
        powerupWhite = PowerUp(imageNamed: "powerup02_1")
        powerupWhite?.setScale(0.85)
        powerupWhite?.physicsBody = SKPhysicsBody(circleOfRadius: powerup!.size.width/200)
        powerupWhite?.position = CGPointMake(1200.0, 445)
        powerupWhite?.physicsBody?.dynamic = false
        powerupWhite?.physicsBody?.collisionBitMask = PhysicsCategory.None
        powerupWhite?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        powerupWhite?.physicsBody?.usesPreciseCollisionDetection = true
        powerupWhite?.runAction(moveObject)
        powerupWhite?.powerUpWhite()

        addChild(powerupWhite!)
    }

    func addBadGuys() {

// for testing
//        let distance = CGFloat(self.frame.size.width * 2.0)
////        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.002 * distance))
//        addBomb()
////        addPowerUpWhite()
//
//        if groundSpeed > 4 {
//            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval((0.008 / groundSpeed) * distance))
//            moveObject = SKAction.sequence([moveObstruction])
//            addMax()
//
//        }

        let y = arc4random_uniform(6)
        if y == 0 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if spriteposition < 25{
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0055  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 50.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0040  * distance))
            } else if spriteposition < 65.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0027  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 75.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0012  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }

            addBomb()

        } else if y == 1 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if spriteposition < 25{
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0055  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 50.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0040  * distance))
            } else if spriteposition < 65.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0025  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 75.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0012  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
            //else if world.groundSpeed < 20.5 {
//                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0018  * distance))
//                moveObject = SKAction.sequence([moveObstruction])
//            }

            addWarhead()

        } else if y == 2 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if spriteposition < 25{
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0055  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 50.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0040  * distance))
            } else if spriteposition < 65.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0028  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 75.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0018  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
            addPowerup()
        } else if y == 3 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if spriteposition < 25{
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0055  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 50.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0040  * distance))
            } else if spriteposition < 65.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0028  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 75.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0018  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }

            addPowerup()
            addBomb()
        } else if y == 4 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if spriteposition < 25 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0055  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 50.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0040  * distance))
            } else if spriteposition < 65.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0026  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 75.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0017  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
            addPowerup()
            addWarhead()
        }
        else {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if spriteposition < 25 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0055  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 50.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0040  * distance))
            } else if spriteposition < 65.0 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0027  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if spriteposition < 75.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0017  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
            addBomb()
            addWarhead()
        }
    }

    func addBomb() {
        bomb = Bomb(imageNamed: "bomb_00")

        bomb?.setScale(0.45)
        bomb?.physicsBody = SKPhysicsBody(circleOfRadius: bomb!.size.width/2)
        bomb?.position = CGPointMake(1458.0, 180)
        bomb?.physicsBody?.dynamic = false
        bomb?.physicsBody?.categoryBitMask = PhysicsCategory.BombCategory
        bomb?.physicsBody?.collisionBitMask = PhysicsCategory.None
        bomb?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        bomb?.physicsBody?.usesPreciseCollisionDetection = true
        bomb?.runAction(moveObject)
        bomb?.bombFlash()

        addChild(bomb!)

        bombExplode = Bomb(imageNamed: "empty")
        bombExplode?.setScale(1.00)
        bombExplode?.position = CGPointMake(bomb!.position.x, bomb!.position.y + 100)
        bombExplode?.runAction(moveObject)

        addChild(bombExplode!)
    }

        func addEdge() {
            let edge = SKNode()

            edge.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0,y: 160,width: self.frame.size.width,height: self.frame.size.height-200))
            edge.physicsBody!.usesPreciseCollisionDetection = true
            edge.physicsBody!.categoryBitMask = PhysicsCategory.Edge
            edge.physicsBody!.dynamic = false
            addChild(edge)
    }

    func playSound(soundVariable: SKAction) {
        runAction(soundVariable)
    }
}

