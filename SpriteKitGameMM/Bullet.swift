//
//  Soldier.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet : SKSpriteNode {

    let gunFire = (0...9).map{ SKTexture(imageNamed: "YellowMuzzle__00\($0)")! }


    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
    }
    

    func shootFire(fireNode: Bullet) {
        runAction(SKAction.repeatAction(SKAction.animateWithTextures(gunFire, timePerFrame: 0.025), count: 2), completion: {
            fireNode.removeFromParent()
        })

    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
