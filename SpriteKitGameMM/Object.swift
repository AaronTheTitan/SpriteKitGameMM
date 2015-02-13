//
//  Object.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/12/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit

class Object: SKNode {

    var hasPhysics:Bool = false

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init (groundDict:Dictionary<String, String>) {
        super.init()

        let image = groundDict["ImageName"] // the image name to display for one or more textures of sprites

        let location:CGPoint = CGPointFromString(groundDict["Location"])
        self.position = location

        if groundDict["PlaceMultiplesOnX"] != nil {

            // put more than one sprite
            let multiples = groundDict["PlaceMultiplesOnX"]!
            let amount:Int = multiples.toInt()!

            // when the road runs out, add more road
            for var i = 0; i < amount; i++ {

                let groundSprite:SKSpriteNode = SKSpriteNode(imageNamed: image!)

                addChild(groundSprite)
                groundSprite.position = CGPoint(x: groundSprite.size.width * CGFloat(i), y: CGFloat(i))

                if (groundDict["BodyType"] == "square") {
                    hasPhysics = true
                    groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundSprite.size)
                    groundSprite.physicsBody?.dynamic = false
                }
            }

        } else {
            // put only one sprite

            let groundSprite:SKSpriteNode = SKSpriteNode(imageNamed: image!)
            addChild(groundSprite)
            // doesn't need positioning set since it will be added in the center of the node

            if (groundDict["BodyType"] == "square") {
                hasPhysics = true
                groundSprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundSprite.size)
                groundSprite.physicsBody?.dynamic = false
            }
        }
    }
}