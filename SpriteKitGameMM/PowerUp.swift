//
//  PowerUp.swift
//  SpriteKitGameMM
//
//  Created by Nick Dobrez on 2/13/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Spritekit

class PowerUp: SKSpriteNode {

    let powerUpBlueNode = (1...6).map{ SKTexture(imageNamed: "powerup01_\($0)")! }
    let powerUpWhiteNode = (1...6).map{ SKTexture(imageNamed: "powerup02_\($0)")! }

//    var orbFlarePath:NSString = NSString()
//    var orbFlare = SKEmitterNode()




    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
    }


    func powerUpBlue() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(powerUpBlueNode, timePerFrame: 0.17)))

//        orbFlarePath = NSBundle.mainBundle().pathForResource("OrbParticle", ofType: "sks")!
//        orbFlare = NSKeyedUnarchiver.unarchiveObjectWithFile(orbFlarePath) as SKEmitterNode
//        orbFlare.position = CGPointMake(1480.0, 620)
//        orbFlare.name = "orbFlare"
//        orbFlare.zPosition = 1
//        orbFlare.targetNode = parent

//        addChild(orbFlare)
    }

    func powerUpWhite() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(powerUpWhiteNode, timePerFrame: 0.17)))

    }


    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
