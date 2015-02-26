//
//  TutorialScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//
import SpriteKit
import AudioToolbox.AudioServices

class TutorialScene: SKScene , SKPhysicsContactDelegate {
    //----- BEGIN DECLARATIONS -----//

    // MARK: - PROPERTIES
    var gameWorld:SKNode?

    var soldierNode:Soldier?
    var warhead:Obstruction!
    var powerup: PowerUp?

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
    //var isGameOver:Bool?

    let spriteposition:CGFloat  = 5
    var moveGroundForeverAction: SKAction!

    let world = WorldGenerator()

    //MARK: - AUDIO
    var soundPowerUp = SKAction.playSoundFileNamed("PowerUpOne.mp3", waitForCompletion: false)
    var soundSuperPowerUp = SKAction.playSoundFileNamed("PowerUpTwo.mp3", waitForCompletion: false)
    var soundJump = SKAction.playSoundFileNamed("Jump.mp3", waitForCompletion: false)

    // MARK: - BUTTONS
    let buttonScenePause   = UIButton.buttonWithType(UIButtonType.System) as UIButton

    // MARK: - GROUND/WORLD
    var moveObject = SKAction()

    let totalGroundPieces = 5

    let startLabel = SKLabelNode(text: "Tap To Start")
    var tapsForStart = 0

    // MARK: - Tutorial
    var orbTutorial = SKSpriteNode(imageNamed: "orbTutorial")
    var jumpTutorial = SKSpriteNode(imageNamed: "jumpTutorial")
    var duckTutorial = SKSpriteNode(imageNamed: "duckTutorial")
    var duckJumpTutorial = SKSpriteNode(imageNamed: "duckJumpTutorial")
    var completeTutorial = SKSpriteNode(imageNamed: "complete")
    var gotItButton = SKSpriteNode(imageNamed: "gotItButtonYellow")
    var firstTimeDuck:Bool?
    var firstTimeJump:Bool?
    var firstTimeDuckJump:Bool?
    var firstTimeOrb:Bool?
    var hasTutorialCompleted:Bool?
    var currentSoldier:String?

    let pauseMenuBG = SKSpriteNode(imageNamed: "gamePausedMenuBG")

    let pauseMenuResume = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let pauseMenuRestart = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let pauseMenuExit = UIButton.buttonWithType(UIButtonType.System) as UIButton

    let pause:String = "pause"
    let resume:String = "resume"

     let removeObject = SKAction.removeFromParent()
    //----- BEGIN LOGIC -----//

    // MARK: - VIEW/SETUP
    override func didMoveToView(view: SKView) {

        currentSoldier = NSUserDefaults.standardUserDefaults().objectForKey("currentSoldierString") as? String

        setupControls(view)

        makeEnemies()

        world.setupScenery()
        addChild(world)
        hasTutorialCompleted = false
        self.physicsWorld.gravity    = CGVectorMake(0, -40)
        physicsWorld.contactDelegate = self
        world.addEdge()

        addSoldier()

        buttonScenePause.setTranslatesAutoresizingMaskIntoConstraints(true)

        startGameLabel()
        firstTimeDuck = false
        firstTimeDuckJump = false
        firstTimeJump = false
        firstTimeOrb = false
        buttonScenePause.hidden = true

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.inGameMusicPlayer.volume = 1
        if appDelegate.isMuted == false {
            appDelegate.stopBGMusic()
            appDelegate.startInGameMusic()
        }

        NSNotificationCenter.defaultCenter().addObserverForName("tutorialPaused", object: nil, queue: nil) { (notification: NSNotification?) in

            self.pauseGame()
            let pausedPlease = NSUserDefaults.standardUserDefaults().boolForKey("isPaused")
            self.scene?.view?.paused = true

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
        if sender.direction == .Up {
            jump()
        } else if sender.direction == .Down {
            duck()
        }
    }

    func handleTaps(sender:UITapGestureRecognizer) {
        if tapsForStart == 0 {
            startGame()
            buttonScenePause.hidden = false
            tapsForStart = 1
        } else if paused == true {
            resumeGame()
            gotItButton.removeFromParent()
            orbTutorial.removeFromParent()
            jumpTutorial.removeFromParent()
            duckTutorial.removeFromParent()
            duckJumpTutorial.removeFromParent()
            completeTutorial.removeFromParent()
        } else {
            jump()
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

    func startGame() {
        //isGameOver = false
        startLabel.removeFromParent()
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run, soldierPrefix:currentSoldier!)
        soldierNode?.stepState(soldierSprites)
        world.startGroundMoving()

        let spawn = SKAction.runBlock({() in self.addBadGuys()})
        var delay = SKAction.waitForDuration(NSTimeInterval(1.85))

        var spawnThenDelay = SKAction.sequence([delay, spawn])
        var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }

    func goToMainMenu() {
        NSNotificationCenter.defaultCenter().postNotificationName("mainMenu", object:nil)
    }

    func pauseGame() {

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.inGameMusicPlayer.volume = 0.3

        updateToSuperView(pause)
        buttonScenePause.hidden = true

        delay(0.01, closure: { () -> () in
            self.view!.paused = true

        })


    }

    func pauseGameTutorial() {
        buttonScenePause.hidden = true
        self.scene!.view!.paused = true
    }

    func resumeGame() {
        updateToSuperView(resume)
        scene?.view?.paused = false
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

    // MARK: - COLLISION FUNCTIONS
    func soldierDidCollideWithSuperPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){
        PowerUp.removeFromParent()
        orbFlare.removeFromParent()
        playSound(soundSuperPowerUp)

    }

    func soldierDidCollideWithBomb(soldier:SKSpriteNode, bomb:SKSpriteNode) {
        bomb.removeFromParent()
        bombExplode?.bombExplode(bombExplode!)

        die()

    }

    func soldierDidCollideWithWarhead(soldier:SKSpriteNode, bomb:SKSpriteNode) {
        warhead.removeFromParent()
        warheadExplode?.warHeadExplode(warheadExplode!, warheadFire: warheadRocket!)

        die()
    }

    func soldierDidCollideWithObstruction(soldier:SKSpriteNode, bomb:SKSpriteNode) {
        upperWarhead.removeFromParent()
        upperWarheadExplode?.warHeadExplode(upperWarheadExplode!, warheadFire: upperWarheadRocket!)

        die()
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
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.WarheadCategory != 0)){
                soldierDidCollideWithWarhead(firstBody.node as SKSpriteNode, bomb: secondBody.node as SKSpriteNode)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0)){
                soldierDidCollideWithObstruction(firstBody.node as SKSpriteNode, bomb: secondBody.node as SKSpriteNode)
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
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

    func restartGame () {

        resumeGame()
        var restartScene = TutorialScene(size: self.size)
        restartScene.scaleMode = .AspectFill
        self.view?.presentScene(restartScene)

        updateToSuperView(resume)
        buttonScenePause.hidden = false
        
    }

    // MARK: - TOUCHES BEGAN
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)

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
    }


    let originalHeroPoint = CGPointMake(450, 450)

    //MARK: - UPDATE
    override func update(currentTime: CFTimeInterval) {

        /* Called before each frame is rendered */

//            soldierNode?.update()
            world.groundMovement()
            groundSpeedIncrease()

            for sprite in world.groundPieces {
                sprite.position.x -= spriteposition
        }
    }

    func resetSoldierPosition() {
        soldierNode?.position.x = originalHeroPoint.x
    }

    var soldierSprites: [[SKTexture]] = []

    // MARK: - ADD ASSETS TO SCENE
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


    // Having fun, can remove in real thang if we want
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
        addChild(upperWarhead!)
        upperWarhead.runAction(SKAction.sequence([moveObject, removeObject]))

        upperWarheadRocket = Bomb(imageNamed: "emptyMuzzle")
        upperWarheadRocket?.position = CGPointMake(upperWarhead.position.x + 115, upperWarhead.position.y)
        upperWarheadRocket?.rocketFire(upperWarheadRocket!)
        addChild(upperWarheadRocket!)
        upperWarheadRocket?.runAction(SKAction.sequence([moveObject, removeObject]))

        upperWarheadExplode = Bomb(imageNamed: "empty")
        upperWarheadExplode?.setScale(0.6)
        upperWarheadExplode?.position = CGPointMake(upperWarhead!.position.x, upperWarhead!.position.y + 95)

        addChild(upperWarheadExplode!)
        upperWarheadExplode?.runAction(SKAction.sequence([moveObject, removeObject]))

    }

    func addDuckWarhead() {

        warhead = Obstruction(imageNamed: "warhead")
        warhead.setScale(0.45)
        warhead.physicsBody = SKPhysicsBody(circleOfRadius: warhead!.size.width/3)
        warhead?.position = CGPointMake(1109.0, 325)
        warhead.physicsBody?.dynamic = false
        warhead.physicsBody?.categoryBitMask = PhysicsCategory.WarheadCategory
        warhead.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        warhead.physicsBody?.usesPreciseCollisionDetection = true
        warhead.physicsBody?.velocity = CGVectorMake(-50, 0)
        //warhead.runAction(moveObject)
        addChild(warhead!)
        warhead?.runAction(SKAction.sequence([moveObject, removeObject]))

        warheadRocket = Bomb(imageNamed: "emptyMuzzle")
        warheadRocket?.position = CGPointMake(warhead.position.x + 120, warhead.position.y)
        warheadRocket?.rocketFire(warheadRocket!)
        //warheadRocket?.runAction(moveObject)
        addChild(warheadRocket!)
        warheadRocket?.runAction(SKAction.sequence([moveObject, removeObject]))

        warheadExplode = Bomb(imageNamed: "empty")
        warheadExplode?.setScale(0.6)
        warheadExplode?.position = CGPointMake(warhead!.position.x, warhead!.position.y + 100)
        //warheadExplode?.runAction(moveObject)

        addChild(warheadExplode!)
        warheadExplode!.runAction(SKAction.sequence([moveObject, removeObject]))

    }

    func addPowerup() {

        if firstTimeOrb == false {
            firstTimeOrb = true
            pauseGameTutorial()
            orbAlertMessage()
        }

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

        orbFlare = NSKeyedUnarchiver.unarchiveObjectWithFile(orbFlarePath) as SKEmitterNode
        orbFlare.position = CGPointMake(1480.0, 620)
        orbFlare.name = "orbFlare"
        orbFlare.zPosition = 1
        orbFlare.targetNode = self
        //orbFlare.runAction(moveObject)
        addChild(orbFlare)
        orbFlare.runAction(SKAction.sequence([moveObject, removeObject]))

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
        if  firstTimeDuck == true && firstTimeDuckJump == true && firstTimeJump == true && firstTimeOrb == true && hasTutorialCompleted == false {

            tutorialIsComplete()
            pauseGameTutorial()
        }

        if scene?.view?.paused == true {
            return
        } else {
            
        let y = arc4random_uniform(6)
        if y == 0 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000967  * distance))
            moveObject = SKAction.sequence([moveObstruction])

            if firstTimeJump == false {
                firstTimeJump = true
                pauseGameTutorial()
                jumpAlertMessage()
            }
            addBomb()

        } else if y == 1 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.000973  * distance))
            moveObject = SKAction.sequence([moveObstruction])

            if firstTimeDuck == false {
                firstTimeDuck = true
                pauseGameTutorial()
                duckAlertMessage()
            }
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
            if firstTimeDuckJump == false {
                firstTimeDuckJump = true
                pauseGameTutorial()
                duckJumpAlertMessage()
            }
            addBomb()
            addDuckWarhead()
        }
        }
    }
    
    func addBomb() {
        bomb = Bomb(imageNamed: "bomb_00")
        
        bomb?.setScale(0.45)
        bomb?.physicsBody = SKPhysicsBody(circleOfRadius: bomb!.size.width/3)
        bomb?.position = CGPointMake(1465.0, 180)
        bomb?.physicsBody?.dynamic = false
        bomb?.physicsBody?.categoryBitMask = PhysicsCategory.BombCategory
        bomb?.physicsBody?.collisionBitMask = PhysicsCategory.None
        bomb?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        bomb?.physicsBody?.usesPreciseCollisionDetection = true
        //bomb?.runAction(moveObject)
        bomb?.bombFlash()
        
        addChild(bomb!)
        bomb!.runAction(SKAction.sequence([moveObject, removeObject]))

        bombExplode = Bomb(imageNamed: "empty")
        bombExplode?.setScale(1.00)
        bombExplode?.position = CGPointMake(bomb!.position.x, bomb!.position.y + 100)
        //bombExplode?.runAction(moveObject)
        
        addChild(bombExplode!)
        bombExplode!.runAction(SKAction.sequence([moveObject, removeObject]))

    }

    
    func playSound(soundVariable: SKAction) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        if appDelegate.isMuted == false {
            runAction(soundVariable)
        }
    }

    func orbAlertMessage(){
        addChild(orbTutorial)
        gotItButtonAdd()
        orbTutorial.size = CGSizeMake(400, 400)
        orbTutorial.position = CGPointMake(500, 435)
    }


    func duckJumpAlertMessage(){
        addChild(duckJumpTutorial)
        gotItButtonAdd()
        duckJumpTutorial.size = CGSizeMake(400, 400)
        duckJumpTutorial.position = CGPointMake(500, 435)

    }

    func jumpAlertMessage(){
        addChild(jumpTutorial)
        gotItButtonAdd()
        jumpTutorial.size = CGSizeMake(400, 400)
        jumpTutorial.position = CGPointMake(500, 435)

    }

    func duckAlertMessage(){
        addChild(duckTutorial)
        gotItButtonAdd()
        duckTutorial.size = CGSizeMake(400, 400)
        duckTutorial.position = CGPointMake(500, 435)

    }

    func gotItButtonAdd() {
        addChild(gotItButton)
        gotItButton.size = CGSizeMake(150, 80)
        gotItButton.position = CGPointMake(500, 340)
        gotItButton.hidden = false
        gotItButton.zPosition = 1.0
        buttonScenePause.hidden = true
    }

    func tutorialIsComplete(){
            hasTutorialCompleted = true
            addChild(completeTutorial)
            completeTutorial.size = CGSizeMake(400, 400)
            completeTutorial.position = CGPointMake(500, 435)
    }
//
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

}
