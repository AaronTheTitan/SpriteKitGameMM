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

//    override init()



//    var currentState = SoldierStates.Idle
//    var isJumping:Bool = false

//    init(spriteTexture: SKTexture) {
//
////        let imageTexture = SKTexture(spriteTexture: spriteTexture)
////        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
//    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}

    func bombSprites() -> [SKTexture] {

        return (0...1).map{ SKTexture(imageNamed: "0\($0)")! }

    }

    func bombAnimate() {
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(bombSprites(), timePerFrame: 0.07)))
    }


}