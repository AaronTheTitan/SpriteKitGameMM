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
    var upperWarhead:Obstruction!
    var upperWarheadRocket:Bomb?
    var upperWarheadExplode:Bomb?
    
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
    let buttonSceneResume = UIButton.buttonWithType(UIButtonType.System) as  UIButton
    let buttonSceneExit = UIButton.buttonWithType(UIButtonType.System) as  UIButton
    let buttonSceneLeaderBroad = UIButton.buttonWithType(UIButtonType.System) as  UIButton

    // MARK: - GROUND/WORLD
    var moveObject = SKAction()

    let totalGroundPieces = 5
    let gameOverMenu = SKSpriteNode(imageNamed: "gameOverMenu")
    let redButton = SKSpriteNode (imageNamed: "goRestart")
    let blueButton = SKSpriteNode (imageNamed: "goLeaderBoard")
    let yellowButton = SKSpriteNode (imageNamed: "goExit")
    let newHighScoreButton = SKSpriteNode(imageNamed: "newHighScore")

    let startLabel = SKLabelNode(text: "Tap To Start")
    var tapsForStart = 0

    var currentSoldier:String?
    var isHighScore = false
    var isHighScoreDefaults:Bool!
    var isPaused = false

    let pauseMenuBG = SKSpriteNode(imageNamed: "gamePausedMenuBG")

    let pauseMenuResume = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let pauseMenuRestart = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let pauseMenuExit = UIButton.buttonWithType(UIButtonType.System) as UIButton

    let pause:String = "pause"
    let resume:String = "resume"
    let removeObject = SKAction.removeFromParent() ////// THIS IS WHERE I WAS


//----- BEGIN LOGIC -----//

// MARK: - VIEW/SETUP
    override func didMoveToView(view: SKView) {

        isHighScoreDefaults = NSUserDefaults.standardUserDefaults().boolForKey("isHighScore")

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.inGameMusicPlayer.volume = 1
        if appDelegate.isMuted == false {
            appDelegate.stopBGMusic()
            appDelegate.startInGameMusic()
        }


        makeEnemies()

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

        startGameLabel()
        
        NSNotificationCenter.defaultCenter().addObserverForName("stayPaused", object: nil, queue: nil) { (notification: NSNotification?) in

            if self.isPaused == false{
            self.pauseGame()
            let pausedPlease = NSUserDefaults.standardUserDefaults().boolForKey("isPaused")
            self.scene?.view?.paused = true
            }


            return
            
        }
    }




    func startGameLabel() {
        startLabel.position = CGPointMake(frame.width/2, frame.height/2)
        startLabel.fontName = "Optima Bold"
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

        scene?.view?.addSubview(buttonScenePause)

    }

    func goToMainMenu() {
        NSNotificationCenter.defaultCenter().postNotificationName("segue", object:nil)
    }

    func startGame() {

        isGameOver = false
        startLabel.removeFromParent()
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run, soldierPrefix:currentSoldier!)
        soldierNode?.stepState(soldierSprites)
        world.startGroundMoving()

        runSpawnActions(isGameOver!)
    }

    func runSpawnActions(gameOver: Bool) {

        if gameOver == false {
            let spawn = SKAction.runBlock({() in self.addBadGuys()})
            let delay = SKAction.waitForDuration(NSTimeInterval(1.29))

            let spawnThenDelay = SKAction.sequence([delay, spawn])
            let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
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
            addChild(newHighScoreButton)
        }

        gameOverMenu.size = CGSizeMake(self.frame.size.width/1.5, self.frame.size.height/1.5)
        gameOverMenu.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 10)

        redButton.setScale(1.0)
        redButton.position = CGPointMake(self.frame.size.width/3, self.frame.size.height/2 + 10)
        redButton.name = "redButton"
        redButton.zPosition = 1.0;

        blueButton.setScale(1.0)
        blueButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 10)
        blueButton.name = "facebook";//how the node is identified later
        blueButton.zPosition = 1.0;

        yellowButton.setScale(1.0)
        yellowButton.position = CGPointMake(self.frame.size.width/1.5, self.frame.size.height/2 + 10)
        yellowButton.name = "yellowButton";//how the node is identified later
        yellowButton.zPosition = 1.0;

        newHighScoreButton.position = CGPointMake(self.frame.size.width/2, CGRectGetMinY(yellowButton.frame) - newHighScoreButton.frame.size.height / 2 - 10)
        newHighScoreButton.name = "highScore"
        newHighScoreButton.zPosition = 1.0;
        newHighScoreButton.setScale(1.0)

        gameOverMenu.hidden = false
        redButton.hidden = false
        blueButton.hidden = false
        yellowButton.hidden = false

        buttonScenePause.removeFromSuperview()
    }

    func setIsPause() {
        NSUserDefaults.standardUserDefaults().setBool(isPaused, forKey: "isPaused")
        let pausedPlease = NSUserDefaults.standardUserDefaults().boolForKey("isPaused")
        NSUserDefaults.standardUserDefaults().synchronize()
        if pausedPlease == true {
            //pauseGame()

        }else {
            self.scene?.view?.paused = false
        }
    }



    func pauseGame() {
        isPaused = true
        if isGameOver == false {


            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.inGameMusicPlayer.volume = 0.3

           updateToSuperView(pause)
           buttonScenePause.hidden = true

            delay(0.01, closure: { () -> () in
                self.view!.paused = true

            })

        }

    }

    func restartGame () {

        resumeGame()
        let restartScene = GameScene(size: self.size)
        restartScene.scaleMode = .AspectFill
        self.view?.presentScene(restartScene)

        updateToSuperView(resume)
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.inGameMusicPlayer.volume = 1
        isPaused = false

        updateToSuperView(resume)
        scene?.view?.paused = false
        buttonScenePause.hidden = false
    }


// MARK: - COLLISION FUNCTIONS
    func soldierDidCollideWithSuperPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){

        if isGameOver == false {

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
            NSUserDefaults.standardUserDefaults().setInteger(scoreInfo.score, forKey: "highscore")
            setscore()

            NSUserDefaults.standardUserDefaults().synchronize()

        }
    }

    func setscore(){
        NSUserDefaults.standardUserDefaults().setBool(isHighScore, forKey: "isHighScore")
        let abool = NSUserDefaults.standardUserDefaults().boolForKey("isHighScore")
        NSUserDefaults.standardUserDefaults().synchronize()
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

    func soldierDidCollideWithObstruction(soldier:SKSpriteNode, bomb:SKSpriteNode) {


        if isGameOver == false {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            isGameOver = true

            upperWarhead.removeFromParent()
            upperWarheadExplode?.warHeadExplode(upperWarheadExplode!, warheadFire: upperWarheadRocket!)

            die()
        }
        self.setIsHighScore()
    }

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
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0)){
                soldierDidCollideWithObstruction(firstBody.node as SKSpriteNode, bomb: secondBody.node as SKSpriteNode)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }

    }


// MARK: - GROUND SPEED MANIPULATION

    func groundSpeedIncrease() {

        let wait = SKAction.waitForDuration(1)
        let run = SKAction.runBlock {

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
        soldierNode?.stepState(soldierSprites)
        playSound(soundJump)
    }

    func duck() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Duck, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(soldierSprites)
    }

    func run() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(soldierSprites)
    }


    func walk() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(soldierSprites)
    }


    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead, soldierPrefix: currentSoldier!)
        soldierNode?.stepState(soldierSprites)

        removeAllActions()

        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:  Selector("gameOver"), userInfo: nil, repeats: false)
    }


//MARK: - UPDATE
    override func update(currentTime: CFTimeInterval) {

        if (world.lastUpdateTime != nil) {
            world.downtime = currentTime - world.lastUpdateTime!
        }else {
            world.downtime = 0
        }

        world.lastUpdateTime = currentTime


        world.groundMovement()
        groundSpeedIncrease()

        if spriteposition < 8 {
            spriteposition = spriteposition + 0.35
        }

        for sprite in world.groundPieces {
            sprite.position.x -= spriteposition
        }
    }

// MARK: - ADD ASSETS TO SCENE

    var soldierSprites: [[SKTexture]] = []

    func addSoldier() {

        soldierNode = Soldier(imageNamed: "\(currentSoldier!)-Walk__000")
        soldierSprites = soldierNode!.initSpritesCache(currentSoldier!)
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
        soldierNode?.stepState(soldierSprites)
    }

    func makeEnemies() {

        upperWarhead = Obstruction(imageNamed: "warhead")
        upperWarheadRocket = Bomb(imageNamed: "emptyMuzzle")
        upperWarheadExplode = Bomb(imageNamed: "empty")
        warhead = Obstruction(imageNamed: "warhead")
        warheadRocket = Bomb(imageNamed: "emptyMuzzle")
        warheadExplode = Bomb(imageNamed: "empty")
        powerup = PowerUp(imageNamed: "powerup")
        bomb = Bomb(imageNamed: "bomb_00")
        bombExplode = Bomb(imageNamed: "empty")

        orbFlarePath = NSBundle.mainBundle().pathForResource("OrbParticle", ofType: "sks")!
    }

    func addWarhead() {

        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random_uniform(height) % (height + height)

        upperWarhead = Obstruction(imageNamed: "warhead")
        upperWarhead.setScale(0.45)
        upperWarhead.physicsBody = SKPhysicsBody(circleOfRadius: upperWarhead!.size.width/3)
        upperWarhead?.position = CGPointMake(1111.0, CGFloat(y + height + 205))
        upperWarhead.physicsBody?.dynamic = false
        upperWarhead.physicsBody?.categoryBitMask = PhysicsCategory.ObstructionCategory
        upperWarhead.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        upperWarhead.physicsBody?.usesPreciseCollisionDetection = true
        upperWarhead.physicsBody?.velocity = CGVectorMake(-50, 0)
        upperWarhead.runAction(moveObject)
        addChild(upperWarhead!)

        upperWarheadRocket = Bomb(imageNamed: "emptyMuzzle")
        upperWarheadRocket?.position = CGPointMake(upperWarhead.position.x + 115, upperWarhead.position.y)
        upperWarheadRocket?.rocketFire(upperWarheadRocket!)
        upperWarheadRocket?.runAction(moveObject)
        addChild(upperWarheadRocket!)

        upperWarheadExplode = Bomb(imageNamed: "empty")
        upperWarheadExplode?.setScale(0.6)
        upperWarheadExplode?.position = CGPointMake(upperWarhead!.position.x, upperWarhead!.position.y + 95)
        upperWarheadExplode?.runAction(moveObject)
        playSound(soundWarhead)

        addChild(upperWarheadExplode!)
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

        addChild(warhead!)
        warhead.runAction(SKAction.sequence([moveObject, removeObject]))

        warheadRocket = Bomb(imageNamed: "emptyMuzzle")
        warheadRocket?.position = CGPointMake(warhead.position.x + 120, warhead.position.y)
        warheadRocket?.rocketFire(warheadRocket!)

        addChild(warheadRocket!)
        warheadRocket?.runAction(SKAction.sequence([moveObject, removeObject]))

        warheadExplode = Bomb(imageNamed: "empty")
        warheadExplode?.setScale(0.6)
        warheadExplode?.position = CGPointMake(warhead!.position.x, warhead!.position.y + 100)

        addChild(warheadExplode!)
        warheadExplode?.runAction(SKAction.sequence([moveObject, removeObject]))

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

        addChild(powerup!)
        powerup?.runAction(SKAction.sequence([moveObject, removeObject]))
        powerup?.powerUpBlue()



        orbFlare = NSKeyedUnarchiver.unarchiveObjectWithFile(orbFlarePath) as SKEmitterNode
        orbFlare.position = CGPointMake(1480.0, 620)
        orbFlare.name = "orbFlare"
        orbFlare.zPosition = 1
        orbFlare.targetNode = self

        addChild(orbFlare)
        orbFlare.runAction(SKAction.sequence([moveObject, removeObject]))

    }


    func addBadGuys() {

        let y = arc4random_uniform(6)
        if y == 0 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000967  * distance))
            moveObject = SKAction.sequence([moveObstruction, removeObject])

            addBomb()

        } else if y == 1 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000973  * distance))
            moveObject = SKAction.sequence([moveObstruction, removeObject])

            addWarhead()
            addDuckWarhead()

        } else if y == 2 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.00098 * distance))
            moveObject = SKAction.sequence([moveObstruction, removeObject])

            addPowerup()

        } else if y == 3 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000963  * distance))
            moveObject = SKAction.sequence([moveObstruction, removeObject])

            addPowerup()
            addBomb()

        } else if y == 4 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000976  * distance))
            moveObject = SKAction.sequence([moveObstruction, removeObject])

            addPowerup()
            addWarhead()
        }
        else {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000882  * distance))
                moveObject = SKAction.sequence([moveObstruction, removeObject])

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
        bomb?.runAction(SKAction.sequence([moveObject, removeObject]))
        bomb?.bombFlash()

        addChild(bomb!)

        bombExplode = Bomb(imageNamed: "empty")
        bombExplode?.setScale(1.00)
        bombExplode?.position = CGPointMake(bomb!.position.x, bomb!.position.y + 100)
        bombExplode?.runAction(SKAction.sequence([moveObject, removeObject]))

        addChild(bombExplode!)
    }

    func playSound(soundVariable: SKAction) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        if appDelegate.isMuted == false {
        runAction(soundVariable)
        }
    }
}
