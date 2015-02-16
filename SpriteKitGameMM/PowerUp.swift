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

    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
    }


    func powerUpBlue() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(powerUpBlueNode, timePerFrame: 0.17)))
    }

    func powerUpWhite() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(powerUpWhiteNode, timePerFrame: 0.17)))

    }


    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
