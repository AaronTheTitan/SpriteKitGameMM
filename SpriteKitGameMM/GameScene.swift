//
//  GameScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//
import SpriteKit
import AudioToolbox.AudioServices
import Social


class GameScene: SKScene , SKPhysicsContactDelegate {
//----- BEGIN DECLARATIONS -----//


    // MARK: - PROPERTIES
    var gameWorld:SKNode?

    var soldierNode:Soldier?
    var obstruction:Obstruction!
    var warhead:Obstruction!
    var powerup: PowerUp?
    var powerupWhite: PowerUp?

    var orbFlarePath:NSString = NSString()
    var orbFlare = SKEmitterNode()


    var bomb:Bomb?
    var bombExplode:Bomb?
    var warheadExplode:Bomb?
    var warheadRocket:Bomb?

    var isRunning:Bool?
    var isGameOver:Bool?
    var isMuted:Bool?
    var spriteposition:CGFloat  = 5
    var moveGroundForeverAction: SKAction!

    let world = WorldGenerator()

    var scoreInfo = ScoreLabel()
    //MARK: - AUDIO
    let soundPowerUp = SKAction.playSoundFileNamed("PowerUpOne.mp3", waitForCompletion: false)
    let soundSuperPowerUp = SKAction.playSoundFileNamed("PowerUpTwo.mp3", waitForCompletion: false)
    let soundJump = SKAction.playSoundFileNamed("Jump.mp3", waitForCompletion: false)
    let soundWarhead = SKAction.playSoundFileNamed("WarheadSound.mp3", waitForCompletion: false)

    // MARK: - BUTTONS
    let buttonScenePause   = UIButton.buttonWithType(UIButtonType.System) as UIButton
//    let buttonScenePlay = UIButton.buttonWithType(UIButtonType.System) as  UIButton
    let buttonSceneResume = UIButton.buttonWithType(UIButtonType.System) as  UIButton
    let buttonSceneExit = UIButton.buttonWithType(UIButtonType.System) as  UIButton
    let buttonSceneLeaderBroad = UIButton.buttonWithType(UIButtonType.System) as  UIButton

    // MARK: - GROUND/WORLD
    var moveObject = SKAction()

    let totalGroundPieces = 5
    let gameOverMenu = SKSpriteNode(imageNamed: "gameOverMenu")
    var redButton = SKSpriteNode (imageNamed: "goRestart")
    var blueButton = SKSpriteNode (imageNamed: "goLeaderBoard")
    var yellowButton = SKSpriteNode (imageNamed: "goExit")
//    var highScoreButton = SKSpriteNode (imageNamed: "menuButtonBlue")
    let newHighScoreButton = SKSpriteNode(imageNamed: "newHighScore")

    let startLabel = SKLabelNode(text: "Tap To Start")
    var tapsForStart = 0

    var currentSoldier:String?
    var isHighScore = false
//    var highScoreLabel = SKLabelNode(text: "New High Score! Congrats")
    var isHighScoreDefaults:Bool!

    let pauseMenuBG = SKSpriteNode(imageNamed: "gamePausedMenuBG")
//    let pauseMenuResume = SKSpriteNode(imageNamed: "pauseMenuResume")
//    let pauseMenuRestart = SKSpriteNode(imageNamed: "pauseMenuRestart")
//    let pauseMenuExit = SKSpriteNode(imageNamed: "pauseMenuExit")

    let pauseMenuResume = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let pauseMenuRestart = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let pauseMenuExit = UIButton.buttonWithType(UIButtonType.System) as UIButton


    let pause:String = "pause"
    let resume:String = "resume"




//----- BEGIN LOGIC -----//

// MARK: - VIEW/SETUP
    override func didMoveToView(view: SKView) {

        isHighScoreDefaults = NSUserDefaults.standardUserDefaults().boolForKey("isHighScore")

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.stopBGMusic()
        appDelegate.startInGameMusic()
        


        currentSoldier = NSUserDefaults.standardUserDefaults().objectForKey("currentSoldierString") as? String

        isGameOver = false
        setupControls(view)

        world.setupScenery()
        addChild(world)

        self.physicsWorld.gravity    = CGVectorMake(0, -40)
        physicsWorld.contactDelegate = self
        world.addEdge()

        addSoldier()
        addChild(scoreInfo)
        scoreInfo.addScoring()


        scoreInfo.labelScore.position = CGPointMake(20 + scoreInfo.labelScore.frame.size.width/2, self.size.height - (120 + scoreInfo.labelScore.frame.size.height/2))
        scoreInfo.highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - (120 + scoreInfo.labelScore.frame.size.height/2))

        let view1 = super.view


        buttonScenePause.setTranslatesAutoresizingMaskIntoConstraints(true)
//        buttonScenePlay.setTranslatesAutoresizingMaskIntoConstraints(true)


        startGameLabel()
        
        NSNotificationCenter.defaultCenter().addObserverForName("stayPausedNotification", object: nil, queue: nil) { (notification: NSNotification?) in

            self.pauseGame()
            println("pause tRhe game please")
            return
            
        }

    }


    func startGameLabel() {
        startLabel.position = CGPointMake(frame.width/2, frame.height/2)
        startLabel.fontName = "MarkerFelt-Wide"
        startLabel.fontSize = 46
        addChild(startLabel)

    }


    func handleSwipes(sender:UISwipeGestureRecognizer) {

        if isGameOver == false {
            if sender.direction == .Up {
                jump()

            } else if sender.direction == .Down {
                duck()
            }
        }
    }

    func handleTaps(sender:UITapGestureRecognizer) {

        if isGameOver == false {
            if tapsForStart == 0 {
                startGame()
                tapsForStart = 1
            } else {
                jump()
            }
        }

         }

    func setupControls(view: SKView) {

        let tapOnce:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTaps:"))
        tapOnce.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapOnce)

        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)

        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)


        let buttonPauseImage = UIImage(named: "buttonPause")
        buttonScenePause.frame = CGRectMake(view.frame.size.width - buttonScenePause.bounds.size.width - 40, 5, 35, 35)
        buttonScenePause.setBackgroundImage(buttonPauseImage, forState: UIControlState.Normal)
        buttonScenePause.addTarget(self, action: "pauseGame", forControlEvents: UIControlEvents.TouchUpInside)


//MARK: - THESE ARE THE NEW PAUSE MENU BUTTONS
        pauseMenuResume.setBackgroundImage(UIImage(named: "pauseMenuResume"), forState: UIControlState.Normal)
        pauseMenuResume.frame = CGRectMake(view.frame.size.width/2 - pauseMenuResume.bounds.size.width - 55, view.frame.size.height/3 - 10, 110, 53)
        pauseMenuResume.addTarget(self, action: "resumeGame", forControlEvents: UIControlEvents.TouchUpInside)

        pauseMenuRestart.setBackgroundImage(UIImage(named: "pauseMenuRestart"), forState: UIControlState.Normal)
        pauseMenuRestart.frame = CGRectMake(view.frame.size.width/2 - pauseMenuRestart.bounds.size.width - 55, view.frame.size.height/2 - 7, 110, 53)
        pauseMenuRestart.addTarget(self, action: "restartGame", forControlEvents: UIControlEvents.TouchUpInside)

        pauseMenuExit.setBackgroundImage(UIImage(named: "pauseMenuExit"), forState: UIControlState.Normal)
        pauseMenuExit.frame = CGRectMake(view.frame.size.width/2 - pauseMenuExit.bounds.size.width - 55, view.frame.size.height/1.5 - 4, 110, 53)

        pauseMenuExit.addTarget(self, action: "goToMainMenu", forControlEvents: UIControlEvents.TouchUpInside)


        pauseMenuBG.size = CGSizeMake(432, 486)
        pauseMenuBG.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 10)
        pauseMenuBG.zPosition = 1.0




//        let buttonPlayImage = UIImage(named: "buttonPlay")
//        buttonScenePlay.frame = CGRectMake(view.frame.size.width - buttonScenePlay.bounds.size.width - 40, 5, 35, 35)
//        buttonScenePlay.setBackgroundImage(buttonPlayImage, forState: UIControlState.Normal)
//        buttonScenePlay.addTarget(self, action: "resumeGame", forControlEvents: UIControlEvents.TouchUpInside)

        scene?.view?.addSubview(buttonScenePause)
//        scene?.view?.addSubview(buttonScenePlay)
//        buttonScenePlay.hidden = true


//        pauseMenuResume.size = CGSizeMake(200, 95)
//        pauseMenuResume.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/1.5 - 50)
//        pauseMenuResume.zPosition = 1.0
//
//
//        pauseMenuRestart.size = CGSizeMake(200, 95)
//        pauseMenuRestart.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 25)
//        pauseMenuRestart.zPosition = 1.0
//
//        pauseMenuExit.size = CGSizeMake(200, 95)
//        pauseMenuExit.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/3)
//        pauseMenuExit.zPosition = 1.0



//        addChild(pauseMenuResume)
//        addChild(pauseMenuRestart)
//        addChild(pauseMenuExit)

    }

    func goToMainMenu() {
        NSNotificationCenter.defaultCenter().postNotificationName("segue", object:nil)
    }

    func startGame() {

//        self.runAction(SKAction.repeatActionForever(SKAction.playSoundFileNamed("ConquerIt.mp3", waitForCompletion: true)))


        isGameOver = false
        startLabel.removeFromParent()
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run, soldierPrefix:currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
        world.startGroundMoving()



        runSpawnActions(isGameOver!)
    }

    func runSpawnActions(gameOver: Bool) {
        if gameOver == false {
            let spawn = SKAction.runBlock({() in self.addBadGuys()})
            var delay = SKAction.waitForDuration(NSTimeInterval(1.29))

            var spawnThenDelay = SKAction.sequence([delay, spawn])
            var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
            self.runAction(spawnThenDelayForever)
        } else {
            removeAllActions()
        }
    }

    func gameOver() {
        isGameOver = true
        runSpawnActions(true)

        tapsForStart = 0

        addChild(gameOverMenu)
        addChild(redButton)
        addChild(blueButton)
        addChild(yellowButton)

        if isHighScore == true {
//            addChild(highScoreLabel)
//            addChild(highScoreButton)
            addChild(newHighScoreButton)

        }

        gameOverMenu.size = CGSizeMake(self.frame.size.width/1.5, self.frame.size.height/1.5)
        gameOverMenu.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 10)

//        redButton.size = CGSizeMake(80, 80)
        redButton.setScale(1.0)
//        redButton.position = CGPointMake(380, 430)
        redButton.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/2)
        redButton.name = "redButton"
        redButton.zPosition = 1.0;

        //(self.frame.size.width/2, self.frame.size.height/1.5 - 50)

//        blueButton.size = CGSizeMake(80, 80)
        blueButton.setScale(1.0)
//        blueButton.position = CGPointMake(500, 430)
        blueButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        blueButton.name = "facebook";//how the node is identified later
        blueButton.zPosition = 1.0;

//        yellowButton.size = CGSizeMake(80, 80)
        yellowButton.setScale(1.0)
//        yellowButton.position = CGPointMake(610, 430)
        yellowButton.position = CGPointMake(self.frame.size.width/1.5, self.frame.size.height/2)
        yellowButton.name = "yellowButton";//how the node is identified later
        yellowButton.zPosition = 1.0;


        //highScoreLabel.size = CGSizeMake(80, 80)
        newHighScoreButton.position = CGPointMake(self.frame.size.width/2, CGRectGetMinY(yellowButton.frame) - newHighScoreButton.frame.size.height / 2)
        newHighScoreButton.name = "highScore"
        newHighScoreButton.zPosition = 1.0;
//        newHighScoreButton.color  = UIColor.blackColor()
//        newHighScoreButton.fontSize = 36
//        newHighScoreButton.fontName = "Noteworthy-Light"

//        newHighScoreButton.position = CGPointMake(300, 330)
//        newHighScoreButton.name = "highScoreButton"
//        newHighScoreButton.zPosition = 1.0
        newHighScoreButton.setScale(1.0)





        gameOverMenu.hidden = false
        redButton.hidden = false
        blueButton.hidden = false
        yellowButton.hidden = false


        buttonScenePause.removeFromSuperview()
//        buttonScenePlay.removeFromSuperview()

//        buttonScenePause.hidden = true
//        buttonScenePlay.hidden = true

    }

//    func gameOverPause() {
//        tapsForStart = 2
//        //scene.view?.paused = true // to pause the game
////        scene?.view?.paused = true
////        buttonscencePause.hidden = true
////        buttonscencePlay.hidden = true
//    }



    func pauseGame() {


        updateToSuperView(pause)


        buttonScenePause.hidden = true
//        buttonScenePlay.hidden = false

        delay(0.01, closure: { () -> () in
            self.view!.paused = true

        })

    }

    func restartGame () {
        updateToSuperView(resume)

        var restartScene = GameScene(size: self.size)
        restartScene.scaleMode = .AspectFill
        self.view?.presentScene(restartScene)

//        buttonScenePlay.hidden = true
        buttonScenePause.hidden = false
        
        
    }

    func updateToSuperView(status: String) {

        if status == pause {
            addChild(pauseMenuBG)
            scene?.view?.addSubview(pauseMenuResume)
            scene?.view?.addSubview(pauseMenuRestart)
            scene?.view?.addSubview(pauseMenuExit)

        } else if status == resume {
            pauseMenuBG.removeFromParent()
            pauseMenuResume.removeFromSuperview()
            pauseMenuRestart.removeFromSuperview()
            pauseMenuExit.removeFromSuperview()

        }
    }


    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }


    func resumeGame() {
        //scene.view?.paused = true // to pause the game

        updateToSuperView(resume)
//        pauseMenuBG.removeAllChildren()
//        pauseMenuResume.removeFromParent()
//        pauseMenuRestart.removeFromParent()
//        pauseMenuExit.removeFromParent()

        scene?.view?.paused = false

        buttonScenePause.hidden = false
//        buttonScenePlay.hidden = true


    }


// MARK: - COLLISION FUNCTIONS
    func soldierDidCollideWithSuperPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){

        if isGameOver == false {
//            isGameOver = true

            PowerUp.removeFromParent()
            scoreInfo.score = scoreInfo.score + 1
            scoreInfo.labelScore.text = "Score: \(scoreInfo.score)"

            orbFlare.removeFromParent()

            playSound(soundSuperPowerUp)

        self.setIsHighScore()

        }
    }

    func setIsHighScore() {
        if scoreInfo.score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
            isHighScore = true
             //println("\(isHighScoreDefaults)")
            NSUserDefaults.standardUserDefaults().setInteger(scoreInfo.score, forKey: "highscore")
            setscore()

            NSUserDefaults.standardUserDefaults().synchronize()

        } else {
            //isHighScore = false
            //println("\(isHighScoreDefaults)")

//            NSUserDefaults.standardUserDefaults().setBool(isHighScore, forKey: "isHighScore")
//            NSUserDefaults.standardUserDefaults().synchronize()
//            let abool = NSUserDefaults.standardUserDefaults().boolForKey("isHighScore")
//            println("setting isHighScore = \(abool)")


        }


//        if scoreInfo.score <= NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
//            isHighScore = false
//            println("\(isHighScoreDefaults)")
//            NSUserDefaults.standardUserDefaults().setInteger(scoreInfo.score, forKey: "highscore")
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isHighScore")
//
//            NSUserDefaults.standardUserDefaults().synchronize()
//            
//        }


    }

    func setscore(){
        NSUserDefaults.standardUserDefaults().setBool(isHighScore, forKey: "isHighScore")
        let abool = NSUserDefaults.standardUserDefaults().boolForKey("isHighScore")
        NSUserDefaults.standardUserDefaults().synchronize()
        //println("setting isHighScore = \(abool)")
    }


    func soldierDidCollideWithBomb(soldier:SKSpriteNode, bomb:SKSpriteNode) {


        if isGameOver == false {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            isGameOver = true

            bomb.removeFromParent()
            bombExplode?.bombExplode(bombExplode!)
            die()
        }

        self.setIsHighScore()

    }

    func soldierDidCollideWithWarhead(soldier:SKSpriteNode, bomb:SKSpriteNode) {


        if isGameOver == false {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            isGameOver = true

            warhead.removeFromParent()
            warheadExplode?.warHeadExplode(warheadExplode!, warheadFire: warheadRocket!)
            die()
        }
        self.setIsHighScore()
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
            (secondBody.categoryBitMask & PhysicsCategory.SuperPowerCategory != 0)){
                 soldierDidCollideWithSuperPowerup(firstBody.node as SKSpriteNode, PowerUp: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.BombCategory != 0)){
                soldierDidCollideWithBomb(firstBody.node as SKSpriteNode, bomb: secondBody.node as SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
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
            let touchedNode = self.nodeAtPoint(location)
            
            if touchedNode.name == "redButton" {

                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
                restartGame()

            }

            if touchedNode.name == "yellowButton" {
                NSNotificationCenter.defaultCenter().postNotificationName("segue", object:nil)
            }



            if touchedNode.name == "facebook" {
                 NSNotificationCenter.defaultCenter().postNotificationName("leader", object:nil)
            }

            if touchedNode.name == "highScore" {
               
                NSNotificationCenter.defaultCenter().postNotificationName("highscore", object:nil)

            }



            if touchedNode.name == "pauseMenuResume" {
                resumeGame()
                println("it works")
            }

            if touchedNode.name == "pauseMenuRestart" {
                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.5)
                restartGame()
            }

            if touchedNode.name == "pauseMenuExit" {
                NSNotificationCenter.defaultCenter().postNotificationName("segue", object:nil)

            }
        }
    }

// MARK: - SOLDIER ACTIONS
    func jump() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Jump, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
        playSound(soundJump)
    }

    func duck() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Duck, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
    }

    func run() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
    }


    func walk() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
    }


    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
        removeAllActions()

        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:  Selector("gameOver"), userInfo: nil, repeats: false)

//        var timer1 = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector:  Selector("gameOverPause"), userInfo: nil, repeats: false)
        //gameOver()
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


        if spriteposition < 8 {
            spriteposition = spriteposition + 0.35
        }


        for sprite in world.groundPieces {
            sprite.position.x -= spriteposition
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

        soldierNode?.setCurrentState(Soldier.SoldierStates.Idle, soldierPrefix:currentSoldier!)
        soldierNode?.stepState(currentSoldier!)
    }

    // Having fun, can remove in real thang if we want
    func addWarhead() {

        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random_uniform(height) % (height + height)

        warhead = Obstruction(imageNamed: "warhead")
        warhead.setScale(0.45)
        warhead.physicsBody = SKPhysicsBody(circleOfRadius: warhead!.size.width/2)
        warhead?.position = CGPointMake(1111.0, CGFloat(y + height + 205))
        warhead.physicsBody?.dynamic = false
        warhead.physicsBody?.categoryBitMask = PhysicsCategory.WarheadCategory
        warhead.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        warhead.physicsBody?.usesPreciseCollisionDetection = true
        warhead.physicsBody?.velocity = CGVectorMake(-50, 0)
        warhead.runAction(moveObject)
        addChild(warhead!)

        playSound(soundWarhead)

        warheadRocket = Bomb(imageNamed: "emptyMuzzle")
        warheadRocket?.position = CGPointMake(warhead.position.x + 120, warhead.position.y)
        warheadRocket?.rocketFire(warheadRocket!)
        warheadRocket?.runAction(moveObject)
        addChild(warheadRocket!)

        warheadExplode = Bomb(imageNamed: "empty")
        warheadExplode?.setScale(0.6)
        warheadExplode?.position = CGPointMake(warhead!.position.x, warhead!.position.y + 100)
        warheadExplode?.runAction(moveObject)

        addChild(warheadExplode!)
    }

    func addDuckWarhead() {

        warhead = Obstruction(imageNamed: "warhead")
        warhead.setScale(0.45)
        warhead.physicsBody = SKPhysicsBody(circleOfRadius: warhead!.size.width/2)
        warhead?.position = CGPointMake(1109.0, 325)
        warhead.physicsBody?.dynamic = false
        warhead.physicsBody?.categoryBitMask = PhysicsCategory.WarheadCategory
        warhead.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        warhead.physicsBody?.usesPreciseCollisionDetection = true
        warhead.physicsBody?.velocity = CGVectorMake(-50, 0)
        warhead.runAction(moveObject)
        addChild(warhead!)

        warheadRocket = Bomb(imageNamed: "emptyMuzzle")
        warheadRocket?.position = CGPointMake(warhead.position.x + 120, warhead.position.y)
        warheadRocket?.rocketFire(warheadRocket!)
        warheadRocket?.runAction(moveObject)
        addChild(warheadRocket!)

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

        orbFlarePath = NSBundle.mainBundle().pathForResource("OrbParticle", ofType: "sks")!
        orbFlare = NSKeyedUnarchiver.unarchiveObjectWithFile(orbFlarePath) as SKEmitterNode
        orbFlare.position = CGPointMake(1480.0, 620)
        orbFlare.name = "orbFlare"
        orbFlare.zPosition = 1
        orbFlare.targetNode = self

        orbFlare.runAction(moveObject)
        addChild(orbFlare)

    }

    func addOrbFlare() {

        let orbFlarePath:NSString = NSBundle.mainBundle().pathForResource("OrbParticle", ofType: "sks")!
        let orbFlare = NSKeyedUnarchiver.unarchiveObjectWithFile(orbFlarePath) as SKEmitterNode
        orbFlare.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 200)
        //        orbFlare.position = CGPointMake(powerupWhite!.position.x, powerupWhite!.position.y)
        orbFlare.name = "orbFlare"
        orbFlare.zPosition = 1
        orbFlare.targetNode = self
        addChild(orbFlare)
    }

    func addBadGuys() {

        let y = arc4random_uniform(6)
        if y == 0 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000967  * distance))
            moveObject = SKAction.sequence([moveObstruction])

            addBomb()

        } else if y == 1 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000973  * distance))
            moveObject = SKAction.sequence([moveObstruction])

            addWarhead()
            addDuckWarhead()

        } else if y == 2 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.00098 * distance))
            moveObject = SKAction.sequence([moveObstruction])

            addPowerup()

        } else if y == 3 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000963  * distance))
            moveObject = SKAction.sequence([moveObstruction])

            addPowerup()
            addBomb()

        } else if y == 4 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000976  * distance))
            moveObject = SKAction.sequence([moveObstruction])

            addPowerup()
            addWarhead()
        }
        else {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000882  * distance))
                moveObject = SKAction.sequence([moveObstruction])

            addBomb()
            addDuckWarhead()
        }
    }

    func addBomb() {
        bomb = Bomb(imageNamed: "bomb_00")

        bomb?.setScale(0.45)
        bomb?.physicsBody = SKPhysicsBody(circleOfRadius: bomb!.size.width/2)
        bomb?.position = CGPointMake(1465.0, 180)
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


    func playSound(soundVariable: SKAction) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        if appDelegate.isMuted == false {
        runAction(soundVariable)
        }
    }
}
