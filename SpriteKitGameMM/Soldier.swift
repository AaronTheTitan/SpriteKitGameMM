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
//    let originalPosition:CGPoint = CGPoint(self.position.x, self.position.y)


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    enum SoldierStates:Int {

        case Idle
        case Walk
        case Run
        case Jump
        case Duck
        case Dead
        case RunShoot
        case WalkShoot


        func sprites() -> [SKTexture] {
            switch self {

            case Idle:
                return (0...9).map{ SKTexture(imageNamed: "Idle__00\($0)")! }

            case Walk:
                return (0...9).map{ SKTexture(imageNamed: "Walk__00\($0)")! }

            case Run:
                return (0...9).map{ SKTexture(imageNamed: "Run__00\($0)")! }

            case Jump:
                return (0...9).map{ SKTexture(imageNamed: "Jump_Shoot__00\($0)")! }

            case Duck:
                return (0...9).map{ SKTexture(imageNamed: "Crouch_Aim__00\($0)")! }

            case .Dead:
                return (0...9).map{ SKTexture(imageNamed: "Dead__00\($0)")! }

            case .RunShoot:
                return (0...9).map{ SKTexture(imageNamed: "Run_Shoot__00\($0)")! }

            case .WalkShoot:
                return (0...9).map{ SKTexture(imageNamed: "Walk_Shoot__00\($0)")! }

            }
        }
    }

    func setCurrentState(currentStateEntry: SoldierStates) {
        currentState = currentStateEntry
    }

    init(imageNamed: String) {

        let imageTexture = SKTexture(imageNamed: imageNamed)
        super.init(texture: imageTexture, color: nil, size: imageTexture.size())

        // may or may not need
        self.physicsBody = SKPhysicsBody(circleOfRadius: (imageTexture.size().width / 2.6))
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.density = 1
        self.physicsBody?.charge = 0.0

    }

    func stepState() {
        switch currentState {

            case .Idle:
                currentState = .Idle
//                self.setScale(normalSize)
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Idle.sprites(), timePerFrame: 0.07)))

            case .Walk:
                currentState = .Walk
//                self.setScale(normalSize)
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Walk.sprites(), timePerFrame: 0.07)))

            case .Run:
                currentState = .Run
//                self.setScale(normalSize)
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Run.sprites(), timePerFrame: 0.04)))

            case .Jump:
                currentState = .Jump
//                self.setScale(normalSize)
                println(isJumping)

                if isJumping == false {
                    isJumping = true
                    println(isJumping)

                    self.physicsBody?.applyImpulse(CGVectorMake(00, 1400))
//                    self.physicsBody?.density = 1
//                    self.physicsBody?.charge = 0.0


                    
                    self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Jump.sprites(), timePerFrame: 0.07), count: 1), completion: { () -> Void in

                        dispatch_after(1, dispatch_get_main_queue()) {
//                            self.runAction(SKAction.moveTo(CGPointMake(self.position.x - 200, self.position.y), duration:0.5))
                            self.isJumping = false
                                            println(self.isJumping)
                        }
                                                    //
//                        self.runAction(SKAction.waitForDuration(1), completion: { () -> Void in
//                            self.position = (CGPointMake(self.position.x - 200, self.position.y))
//                        })



//                        dispatch_after(1, dispatch_get_main_queue()) {
////                            self.position = (CGPointMake(self.position.x - 200, self.position.y))
//
//                        }


//                        self.runAction(SKAction.moveTo(CGPointMake(self.position.x - 200, self.position.y), duration:2))

                    }
                )

            }

            case .Duck:
                currentState = .Duck
                self.setScale(duckingSize)
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Duck.sprites(), timePerFrame: 0.07), count: 1), completion: { () -> Void in
                    self.setScale(self.normalSize)
                        }
                    )

            case .Dead:
                currentState = .Dead
//                self.setScale(normalSize)
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Dead.sprites(), timePerFrame: 0.07), count: 1))

            case .RunShoot:
                currentState = .RunShoot
//                self.setScale(normalSize)
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.RunShoot.sprites(), timePerFrame: 0.05), count: 1))

            case .WalkShoot:
//                self.setScale(normalSize)
                currentState = .WalkShoot
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.WalkShoot.sprites(), timePerFrame: 0.07), count: 1))

        }
    }



    func update() {
        // update when told by the GameScene class
        
        
//        if currentState == .Crouch {
//            self.setScale(duckingSize)
//        } else {
//            self.setScale(normalSize)
//        }
//
//        if currentState == .Jump {
//
//        }
//
//        if currentState == .RunShoot {
//
//        }
    }
}
