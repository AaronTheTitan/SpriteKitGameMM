//
//  GameScene.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//
import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate {


    // MARK: - PROPERTIES
   // var increment = 0

    var gameWorld:SKNode?

    var soldierNode:Soldier?
    var girlSoldierNode:GirlSoldier? // testing for adding another player for selection
    var obstruction:Obstruction!
    var max:Obstruction! // playing around
    var moveObject = SKAction()
    var platform:Platform?
    var powerup: PowerUp?
    var powerupWhite: PowerUp?
    var highScoreLabel:SKLabelNode!
    var labelScore:SKLabelNode!
    var score: Int!
    var highScore:NSInteger?
    var bomb:Bomb?
//    var warhead:Bomb?
    var bombExplode:Bomb?
    var warheadExplode:Bomb?
    var isRunning:Bool?

    var soundPowerUp = SKAction.playSoundFileNamed("PowerUpOne.mp3", waitForCompletion: false)
    var soundSuperPowerUp = SKAction.playSoundFileNamed("PowerUpTwo.mp3", waitForCompletion: false)
    var soundJump = SKAction.playSoundFileNamed("Jump.mp3", waitForCompletion: false)

    // MARK: - PHYSICS CATEGORY STRUCT
    var used:Bool?

    //allows us to differentiate sprites
    struct PhysicsCategory {
        static let None                : UInt32 = 0
        static let SoldierCategory     : UInt32 = 0b1       //1
        static let ObstructionCategory : UInt32 = 0b10      //2
        static let Edge                : UInt32 = 0b100     //3
        static let PlatformCategory    : UInt32 = 0b1000    //4
        static let PowerupCategory     : UInt32 = 0b10000   //5
        static let SuperPowerCategory  : UInt32 = 0b100000  //6
        static let BombCategory        : UInt32 = 0b1000000 //7
        static let WarheadCategory     : UInt32 = 0b10000000 //8

    }

    // MARK: - BUTTONS
    let buttonJump    = SKSpriteNode(imageNamed: "directionUpRed")
    let buttonDuck    = SKSpriteNode(imageNamed: "directionDownRed")
    let buttonFire    = SKSpriteNode(imageNamed: "fireButtonRed")
    let buttonPause   = SKSpriteNode(imageNamed: "buttonPause")
    let buttonPlay    = SKSpriteNode(imageNamed: "buttonPlay")

    // MARK: - STATUS HOLDERS
    // Status Holders
    let healthStatus  = SKSpriteNode(imageNamed: "healthStatus")
    let scoreKeeperBG = SKSpriteNode(imageNamed: "scoreKeepYellow")

    // MARK: - GROUND/WORLD
    let totalGroundPieces = 5
    var groundPieces = [SKSpriteNode]()

    var groundSpeed: CGFloat = 1.0
    var moveGroundAction: SKAction!
    var moveGroundForeverAction: SKAction!
    let groundResetXCoord: CGFloat = -500
    var timeIncrement:Double = 0.001



    // MARK: - VIEW/SETUP
    override func didMoveToView(view: SKView) {

        gameWorld = SKNode()
        addChild(gameWorld!)

        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)

        let tapShoot:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTaps:"))
        tapShoot.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapShoot)

        //added for collision detection
        //        view.showsPhysics = true
        initSetup()
        setupScenery()
        startGame()

         self.physicsWorld.gravity    = CGVectorMake(0, -40)
         physicsWorld.contactDelegate = self
         var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("groundSpeedIncrease"), userInfo: nil, repeats: true)


        //adds soldier, moved to function to clean up
        addSoldier()
        //addGirlSoldier()

        // soldier is NOT running at the start...used to determine which animation will trigger when shooting
        isRunning = false

        //add an edge to keep soldier from falling forever. This currently has the edge just off the screen, needs to be fixed.
        addEdge()

        // PUT THIS STUFF INTO A SEPERATE GAME BUTTON CONTROLLERS CLASS
        addButtons()
        score = 0
        highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")

//        NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];

        addScoreLabel()
        addHighScoreLabel()
//        addBombs() // testing out bombs
        let distance = CGFloat(self.frame.size.width * 2.0)
        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.05 * distance))
        moveObject = SKAction.sequence([moveObstruction])

        let spawn = SKAction.runBlock({() in self.addBadGuys()})
        var delay = SKAction.waitForDuration(NSTimeInterval(2.9))
//        if  groundSpeed > 17.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(0.1))
//        } else if groundSpeed > 16 {
//            delay = SKAction.waitForDuration(NSTimeInterval(0.35))
//            println("Delay at .35")
//        } else if groundSpeed > 14.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(0.6))
//            println("Delay at .6")
//        } else if groundSpeed > 10.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(1.1))
//            println("Delay at 1.1")
//        } else if groundSpeed > 6.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(1.5))
//        }
        var spawnThenDelay = SKAction.sequence([spawn,delay])
        println("Delay in thing: \(delay)")
        var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)


    }

//    override func didSimulatePhysics() {
//        self.centerOnNode(soldierNode!)
//    }

//    func centerOnNode(node: SKNode) {
//        var cameraPosition:CGPoint = self.convertPoint(node.position, fromNode: node.parent!)
//        cameraPosition.x = 0
//        node.parent!.position = CGPointMake(node.parent!.position.x - cameraPosition.x, node.parent!.position.y - cameraPosition.y)
//
//    }



//    func delayAndSpawn(){
//        
//        let spawn = SKAction.runBlock({() in self.addBadGuys()})
//        var delay = SKAction.waitForDuration(NSTimeInterval(2.7))
//        if  groundSpeed > 17.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(0.4))
//        } else if groundSpeed > 16 {
//            delay = SKAction.waitForDuration(NSTimeInterval(0.55))
//            println("Delay at .35")
//        } else if groundSpeed > 14.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(0.8))
//            println("Delay at .6")
//        } else if groundSpeed > 10.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(1.1))
//            println("Delay at 1.1")
//        } else if groundSpeed > 6.0 {
//            delay = SKAction.waitForDuration(NSTimeInterval(1.5))
//        }
//        var spawnThenDelay = SKAction.sequence([spawn,delay])
//        println("Delay in thing: \(delay)")
//        var spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
//
//        self.runAction(spawnThenDelay)
//    }

    func handleSwipes(sender:UISwipeGestureRecognizer) {
        jump()
    }

    func handleTaps(sender:UITapGestureRecognizer) {

        if isRunning == false {
            walkShoot()
        } else {
            runShoot()
        }
    }

    //TODO: Change font size based on phone that is being used
    //TODO: Do we want score in the middle?
    func addScoreLabel(){
        labelScore = SKLabelNode(text: "Score: \(score)")
        labelScore.fontName = "MarkerFelt-Wide"
        labelScore.fontSize = 24
        labelScore.zPosition = 4
        //labelScore.position = CGPointMake(500, 625)
        labelScore.position = CGPointMake(30 + labelScore.frame.size.width/2, self.size.height - (107 + labelScore.frame.size.height/2))
        addChild(labelScore)
    }

//TODO: Make Highscore same level as score
    func addHighScoreLabel(){
        highScoreLabel = SKLabelNode(text: "Highscore: \(highScore!)")
        highScoreLabel.fontName = "MarkerFelt-Wide"
        highScoreLabel.fontSize  = 24
        highScoreLabel.zPosition = 4
        highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.835)
        addChild(highScoreLabel)
}

    // MARK: - COLLISION FUNCTIONS
    //when Soldier collides with Obsturction, do this function (currently does nothing)
    func soldierDidCollideWithObstacle(Soldier:SKSpriteNode, Obstruction:SKSpriteNode) {
        if soldierNode!.color == UIColor.greenColor() {
            let changeColorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5)
            soldierNode!.runAction(changeColorAction)
        }

    }

    func soldierDidCollideWithPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){
//        let changeColorAction = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.5)
//        soldierNode!.runAction(changeColorAction)
        PowerUp.removeFromParent()
        score = score + 1
        labelScore.text = "Score: \(score)"

        playSound(soundPowerUp)

        if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }

    }

    func soldierDidCollideWithSuperPowerup(Soldier:SKSpriteNode, PowerUp:SKSpriteNode){
        PowerUp.removeFromParent()
        score = score + 2
        labelScore.text = "Score: \(score)"

        playSound(soundSuperPowerUp)

        if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func soldierDidCollideWithBomb(Soldier:SKSpriteNode, Bomb:SKSpriteNode) {
        Bomb.removeFromParent()
        bombExplode?.bombExplode()
        die()
    }

    func soldierDidCollideWithWarhead(Soldier:SKSpriteNode, Bomb:SKSpriteNode) {
        max.removeFromParent()
        warheadExplode?.warHeadExplode()
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
            (secondBody.categoryBitMask & PhysicsCategory.ObstructionCategory != 0)) {
                soldierDidCollideWithObstacle(firstBody.node as SKSpriteNode, Obstruction: secondBody.node as SKSpriteNode)
                //die()
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.PowerupCategory != 0)){
                //TO DO: FOUND NIL UNWRAPPING OPTIONAL VALUE HERE
                soldierDidCollideWithPowerup(firstBody.node as SKSpriteNode, PowerUp: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.SuperPowerCategory != 0)){
                 soldierDidCollideWithSuperPowerup(firstBody.node as SKSpriteNode, PowerUp: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.BombCategory != 0)){
                soldierDidCollideWithBomb(firstBody.node as SKSpriteNode, Bomb: secondBody.node as SKSpriteNode)
        } else if ((firstBody.categoryBitMask & PhysicsCategory.SoldierCategory != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.WarheadCategory != 0)){
                soldierDidCollideWithWarhead(firstBody.node as SKSpriteNode, Bomb: secondBody.node as SKSpriteNode)
        }

    }

    func didEndContact(contact: SKPhysicsContact) {
        // will get called automatically when two objects end contact with each other
    }

    // MARK: - GROUND SPEED MANIPULATION

    func groundSpeedIncrease(){
        if groundSpeed < 15 {
            groundSpeed = groundSpeed + 0.2
            println("ground speed \(groundSpeed)")
        } else if groundSpeed < 17.24 {
            groundSpeed = groundSpeed + 0.03
        } else {

        }


        var speedUpAction = SKAction.speedTo(groundSpeed, duration: (NSTimeInterval(timeIncrement)))
        for sprite in groundPieces
        {
            sprite.runAction(speedUpAction)
        }
//        println("\(groundSpeed)")
        if groundSpeed > 10.5 {
            run()
            isRunning = true
            println("ground speed \(groundSpeed)")
        }

    }

    // MARK: - INIT SETUP FUNCTIONS
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

    // MARK: - TOUCHES BEGAN
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//         Called when a touch begins 
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
            soldierNode?.stepState()

            girlSoldierNode?.setCurrentState(GirlSoldier.SoldierStates.Walk)
            girlSoldierNode?.stepState()

            if CGRectContainsPoint(buttonJump.frame, location ) {
                jump()

            } else if CGRectContainsPoint(buttonDuck.frame, location) {
                duck()
                //can delete, just reference in case we want to change colors :)
                //let changeColorAction = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 1.0, duration: 0.5)
               //soldierNode!.runAction(changeColorAction)

            } else if CGRectContainsPoint(buttonFire.frame, location) {
                walkShoot()
            }
        }
    }

    // MARK: - SOLDIER ACTIONS

    func jump() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Jump)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Jump)

        playSound(soundJump)
    }

    func duck() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Crouch)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Crouch)
    }

    func run() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Run)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Run)

    }

    func runShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.RunShoot)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.RunShoot)

        var fireShot = Bullet(imageNamed: "emptyMuzzle")
        addChild(fireShot)
        fireShot.position = CGPointMake(soldierNode!.position.x + 132, soldierNode!.position.y)
        fireShot.shootFire(fireShot)
    }

    func walkShoot() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.WalkShoot)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.WalkShoot)

        var fireShot = Bullet(imageNamed: "emptyMuzzle")
        addChild(fireShot)
        fireShot.position = CGPointMake(soldierNode!.position.x + 132, soldierNode!.position.y)
        fireShot.shootFire(fireShot)
    }

    func walk() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Walk)
    }


    func die() {
        soldierNode?.setCurrentState(Soldier.SoldierStates.Dead)
        soldierNode?.stepState()
        girlFollowDelay(GirlSoldier.SoldierStates.Dead)
    }

    let originalHeroPoint = CGPointMake(450, 450)

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if soldierNode?.position.x < originalHeroPoint.x - 300 || soldierNode?.position.x > originalHeroPoint.x + 300 {
                resetSoldierPosition()
        }

        soldierNode?.update()
        groundMovement()
    }

    func resetSoldierPosition() {
        soldierNode?.position.x = originalHeroPoint.x
    }

    func girlFollowDelay(state: GirlSoldier.SoldierStates) {
        let delay = 0.07 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, dispatch_get_main_queue()) {
            self.girlSoldierNode?.setCurrentState(state)
            self.girlSoldierNode?.stepState()
        }
    }


    // MARK: - ADD ASSETS TO SCENE
    //add a soldier, called in did move to view
    func addSoldier(){
        soldierNode = Soldier(imageNamed: "Walk__000")
        //was 300, 300

        soldierNode?.position = CGPointMake(250, 450)

        soldierNode?.setScale(0.35)
        soldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: soldierNode!.size)
        soldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        soldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.PlatformCategory
        soldierNode?.physicsBody?.contactTestBitMask = PhysicsCategory.ObstructionCategory | PhysicsCategory.PowerupCategory | PhysicsCategory.SuperPowerCategory | PhysicsCategory.BombCategory | PhysicsCategory.WarheadCategory
        soldierNode?.physicsBody?.allowsRotation = false
        soldierNode?.physicsBody?.usesPreciseCollisionDetection = true

        addChild(soldierNode!)

        soldierNode?.setCurrentState(Soldier.SoldierStates.Walk)
        soldierNode?.stepState()

    }
//    func addfireShot() {
//        fireShot = Bullet(imageNamed: "emptyMuzzle")
//        addChild(fireShot!)
//    }

    //need to update girlPhysics catergories
    func addGirlSoldier() {
        girlSoldierNode = GirlSoldier(imageNamed: "G-Walk__000")
        girlSoldierNode?.position = CGPointMake(300, 450)
        girlSoldierNode?.setScale(0.35)
        girlSoldierNode?.physicsBody = SKPhysicsBody(rectangleOfSize: girlSoldierNode!.size)
        girlSoldierNode?.physicsBody?.allowsRotation = false
        girlSoldierNode?.physicsBody?.categoryBitMask = PhysicsCategory.SoldierCategory
        girlSoldierNode?.physicsBody?.collisionBitMask = PhysicsCategory.Edge //| PhysicsCategory.ObstructionCategory
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
        //obstruction.physicsBody?.collisionBitMask   = PhysicsCategory.SoldierCategory
        obstruction.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        obstruction.physicsBody?.usesPreciseCollisionDetection = true
        obstruction.runAction(moveObject)

        addChild(obstruction!)
    }

    // Having fun, can remove in real thang if we want
    func addMax(){

        max = Obstruction(imageNamed: "warhead")
        max.setScale(0.65)

        max.physicsBody = SKPhysicsBody(circleOfRadius: max!.size.width/2)
        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random_uniform(height) % height + height
        max?.position = CGPointMake(1200.0, CGFloat(y + height))
        max.physicsBody?.dynamic = false
        max.physicsBody?.categoryBitMask = PhysicsCategory.WarheadCategory
       // max.physicsBody?.collisionBitMask = PhysicsCategory.SoldierCategory
        max.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        max.physicsBody?.usesPreciseCollisionDetection = true
        max.runAction(moveObject)

        addChild(max!)


        warheadExplode = Bomb(imageNamed: "empty")
        warheadExplode?.setScale(2.00)
        warheadExplode?.position = CGPointMake(max!.position.x, max!.position.y + 100)
        warheadExplode?.runAction(moveObject)

        addChild(warheadExplode!)

    }

    func addPlatform() {
        platform = Platform(imageNamed: "platform")
        // max.setScale(0.45)
        platform?.setScale(1.1)
        platform?.physicsBody = SKPhysicsBody(circleOfRadius: platform!.size.width/2)
        platform?.position = CGPointMake(1190.0, 380)
        platform?.physicsBody?.dynamic = false
        platform?.physicsBody?.categoryBitMask = PhysicsCategory.PlatformCategory
        platform?.physicsBody?.collisionBitMask = PhysicsCategory.SoldierCategory
        platform?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        platform?.physicsBody?.usesPreciseCollisionDetection = true
        platform?.runAction(moveObject)
        
        addChild(platform!)
    }

    func addPowerup() {
        powerup = PowerUp(imageNamed: "powerup")
        // max.setScale(0.45)
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
        powerupWhite?.physicsBody?.categoryBitMask = PhysicsCategory.PowerupCategory
        powerupWhite?.physicsBody?.collisionBitMask = PhysicsCategory.None
        powerupWhite?.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
        powerupWhite?.physicsBody?.usesPreciseCollisionDetection = true
        powerupWhite?.runAction(moveObject)
        powerupWhite?.powerUpWhite()

        addChild(powerupWhite!)
    }

    func addBadGuys() {
//        let distance = CGFloat(self.frame.size.width * 2.0)
//        let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.005 * distance))
//        moveObject = SKAction.sequence([moveObstruction])

        let y = arc4random_uniform(3)
        if y == 0 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if groundSpeed < 5.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0067  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if groundSpeed < 12.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0050  * distance))
            } else if groundSpeed < 15.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0038  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if groundSpeed < 16.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0025  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }else if groundSpeed < 20.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0018  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
            //addDon()
            addBomb()
        } else if y == 1 {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if groundSpeed < 5.5{
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0067  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if groundSpeed < 12.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0050  * distance))
            } else if groundSpeed < 15.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0038  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if groundSpeed < 16.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0025  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }else if groundSpeed < 20.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0018  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
            addMax ()

        } else {
            let distance = CGFloat(self.frame.size.width * 2.0)
            if groundSpeed < 5.5{
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0067  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if groundSpeed < 12.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0050  * distance))
            } else if groundSpeed < 15.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0038  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            } else if groundSpeed < 16.55 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0025  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }else if groundSpeed < 20.5 {
                let moveObstruction = SKAction.moveByX(-distance, y: 0.0, duration: NSTimeInterval(0.0018  * distance))
                moveObject = SKAction.sequence([moveObstruction])
            }
           //addPlatform()
            addPowerup()
            //addPowerUpWhite()
            //addBomb()
        }
    }

    func addBomb() {
        bomb = Bomb(imageNamed: "bomb_00")
        // max.setScale(0.45)
        bomb?.setScale(0.45)
        bomb?.physicsBody = SKPhysicsBody(circleOfRadius: bomb!.size.width/2)
        bomb?.position = CGPointMake(1280.0, 180)
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

//    func addWarhead() {
//        warhead = Bomb(imageNamed: "warHead")
//        warhead?.setScale(0.65)
//
//        warhead?.physicsBody = SKPhysicsBody(circleOfRadius: bomb!.size.width/2)
//
//        let height = UInt32(self.frame.size.height / 4)
//        let y = arc4random_uniform(height) % height + height
//        warhead?.position = CGPointMake(1200.0, CGFloat(y + height))
//        warhead.physicsBody?.dynamic = false
//        warhead.physicsBody?.categoryBitMask = PhysicsCategory.BombCategory
//        // max.physicsBody?.collisionBitMask = PhysicsCategory.SoldierCategory
//        warhead.physicsBody?.contactTestBitMask = PhysicsCategory.SoldierCategory
//        warhead.physicsBody?.usesPreciseCollisionDetection = true
//        warhead.runAction(moveObject)
//
//        addChild(warhead!)
//    }

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
//        buttonJump.position = CGPointMake(75, 400)
//        buttonJump.setScale(1.6)
//        addChild(buttonJump)

//        buttonDuck.position = CGPointMake(75, 200)
//        buttonDuck.setScale(1.6)
//        addChild(buttonDuck)

//        buttonFire.position = CGPointMake(60, 300)
//        buttonFire.setScale(1.6)
//        addChild(buttonFire)

        healthStatus.position = CGPointMake(100, 630)
        healthStatus.setScale(1.1)
        addChild(healthStatus)

//        scoreKeeperBG.position = CGPointMake(950, 610)
//        scoreKeeperBG.setScale(1.3)
//        addChild(scoreKeeperBG)

        buttonPause.position = CGPointMake(50, 150)
        buttonPause.setScale(1.4)
        buttonPause.hidden = false
        addChild(buttonPause)

        // play button hidden until pause button hit.
        buttonPlay.position = buttonPause.position
        buttonPlay.size = buttonPause.size
        buttonPlay.hidden = true
        addChild(buttonPlay)
    }

    func playSound(soundVariable: SKAction) {
        runAction(soundVariable)

    }




//    func addBombs() {
//        var bomb = Bomb()
//
//        bomb.position = CGPointMake(400, 450)
//
//        bomb.bombAnimate()
//        addChild(bomb)
//
//
//    }


}

