//
//  Soldier.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit


class Soldier : SKSpriteNode {

    var currentState = SoldierStates.Idle
    var isJumping:Bool = false
    let normalSize:CGFloat = 0.32
    let duckingSize:CGFloat = 0.20
    var cgVector:CGVector = CGVectorMake(00, 1400)
    var aString = "aString"


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())

        self.physicsBody = SKPhysicsBody(circleOfRadius: (imageTexture.size().width / 2.6))
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.density = 1
        self.physicsBody?.charge = 0.0
    }




    var cache: [[SKTexture]] = []
    func initSpritesCache(soldierPrefix: String) -> Array<[SKTexture]> {

        cache.append((0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Idle__00\($0)")! })
        cache.append((0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Walk__00\($0)")! })
        cache.append((0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Run__00\($0)")! })
        cache.append((0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Jump_Shoot__00\($0)")! })
        cache.append((0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Crouch_Aim__00\($0)")! })
        cache.append((0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Dead__00\($0)")! })

        return cache

    }

    func sprites(state: SoldierStates) -> [SKTexture] {
        return cache[state.rawValue]

    }



    enum SoldierStates:Int {

        case Idle
        case Walk
        case Run
        case Jump
        case Duck
        case Dead



        func sprites(spritesArray: Array<[SKTexture]>) -> [SKTexture] {

            switch self {

            case Idle:
                return spritesArray[0]

            case Walk:
                return spritesArray[1]

            case Run:
                return spritesArray[2]

            case Jump:
                return spritesArray[3]

            case Duck:
                return spritesArray[4]

            case .Dead:
                return spritesArray[5]
                
            }
        }
    }




//    enum SoldierStates:Int {
//
//        case Idle
//        case Walk
//        case Run
//        case Jump
//        case Duck
//        case Dead
//
//
//
//        func sprites(soldierPrefix: String) -> [SKTexture] {
//
//            switch self {
//
//            case Idle:
//                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Idle__00\($0)")! }
//
//            case Walk:
//                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Walk__00\($0)")! }
//
//            case Run:
//                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Run__00\($0)")! }
//
//            case Jump:
//                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Jump_Shoot__00\($0)")! }
//
//            case Duck:
//                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Crouch_Aim__00\($0)")! }
//
//            case .Dead:
//                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Dead__00\($0)")! }
//
//            }
//        }
//    }

    func setCurrentState(currentStateEntry: SoldierStates, soldierPrefix: String) {
        currentState = currentStateEntry
    }



    func stepState(spritesArray: Array<[SKTexture]>) {
        switch currentState {

            case .Idle:
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Idle.sprites(spritesArray), timePerFrame: 0.07)))

            case .Walk:
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Walk.sprites(spritesArray), timePerFrame: 0.07)))

            case .Run:
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Run.sprites(spritesArray), timePerFrame: 0.04)))

            case .Jump:
                println(NSDate().timeIntervalSinceReferenceDate)

                self.setScale(normalSize)
                if isJumping == false {

                    isJumping = true
                    self.physicsBody?.applyImpulse(cgVector)
                    self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Jump.sprites(spritesArray), timePerFrame: 0.07), count: 1), completion: { () -> Void in

                        dispatch_after(1, dispatch_get_main_queue()) {
                            self.isJumping = false
                        }
                    })
            }

            case .Duck:

                self.setScale(duckingSize)
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Duck.sprites(spritesArray), timePerFrame: 0.07), count: 1), completion: { () -> Void in
                    self.setScale(self.normalSize)
                        }
                    )

            case .Dead:
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Dead.sprites(spritesArray), timePerFrame: 0.07), count: 1))
        }
    }



//    func update() {
//        // update when told by the GameScene class
//
//    }
}
