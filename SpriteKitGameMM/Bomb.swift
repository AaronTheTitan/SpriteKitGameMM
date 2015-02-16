//
//  Bomb.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/13/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit

class Bomb : SKSpriteNode {

    let bombNode = (0...1).map{ SKTexture(imageNamed: "bomb_0\($0)")! }
    let explosion = (0...10).map{ SKTexture(imageNamed: "GroundExplo__00\($0)")! }

    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
    }


    func bombFlash() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(bombNode, timePerFrame: 0.17)))
    }

    func bombExplode() {
        runAction(SKAction.repeatAction(SKAction.animateWithTextures(explosion, timePerFrame: 0.14), count: 1))
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}




}