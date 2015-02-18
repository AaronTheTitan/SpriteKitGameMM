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

    let soundExplosion = SKAction.playSoundFileNamed("Explosion.mp3", waitForCompletion: false)

    let bombNode = (0...1).map{ SKTexture(imageNamed: "bomb_0\($0)")! }
    let explosion = (0...9).map{ SKTexture(imageNamed: "GroundExplo__00\($0)")! }
    let explosionInAir = (0...9).map{ SKTexture(imageNamed: "MidAirExplo__00\($0)")! }
    let warheadRocketFire = (0...9).map{ SKTexture(imageNamed: "YellowMuzzle__00\($0)")! }
    var rocketFireFromScene:Bomb?


    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
    }


    func bombFlash() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(bombNode, timePerFrame: 0.17)))
    }

    func bombExplode(explodeNode: SKSpriteNode) {
        runAction(SKAction.repeatAction(SKAction.animateWithTextures(explosion, timePerFrame: 0.14), count: 1), completion: {
            explodeNode.removeFromParent()
        })
        runAction(soundExplosion)

//        , completion: {
//        explodeNode.removeFromParent()
//        })


    }


    func rocketFire(fireNode: Bomb) {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(warheadRocketFire, timePerFrame: 0.025)))
        rocketFireFromScene = fireNode
//        runAction(SKAction.repeatAction(SKAction.animateWithTextures(warheadRocketFlames, timePerFrame: 0.025), count: 2), completion: {
//            fireNode.removeFromParent()
//        })

    }


    func warHeadExplode(warhead: SKSpriteNode) {
        runAction(SKAction.repeatAction(SKAction.animateWithTextures(explosionInAir, timePerFrame: 0.14), count: 1), completion: {
            warhead.removeFromParent()
            self.rocketFireFromScene?.removeFromParent()
        })
        runAction(soundExplosion)

    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
}




}