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

        // may or may not need
        self.physicsBody = SKPhysicsBody(circleOfRadius: (imageTexture.size().width / 2.6))
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.density = 1
        self.physicsBody?.charge = 0.0
        
    }


    enum SoldierStates:Int {

        case Idle
        case Walk
        case Run
        case Jump
        case Duck
        case Dead


        func sprites(soldierPrefix: String) -> [SKTexture] {

            switch self {

            case Idle:
                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Idle__00\($0)")! }

            case Walk:
                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Walk__00\($0)")! }

            case Run:
                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Run__00\($0)")! }

            case Jump:
                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Jump_Shoot__00\($0)")! }

            case Duck:
                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Crouch_Aim__00\($0)")! }

            case .Dead:
                return (0...9).map{ SKTexture(imageNamed: "\(soldierPrefix)-Dead__00\($0)")! }

            }
        }
    }

    func setCurrentState(currentStateEntry: SoldierStates, soldierPrefix: String) {
        currentState = currentStateEntry
    }



    func stepState(soldierSelected: String) {
        switch currentState {

            case .Idle:
//                currentState = .Idle
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Idle.sprites(soldierSelected), timePerFrame: 0.07)))

            case .Walk:
//                currentState = .Walk
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Walk.sprites(soldierSelected), timePerFrame: 0.07)))

            case .Run:
//                currentState = .Run
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Run.sprites(soldierSelected), timePerFrame: 0.04)))

            case .Jump:
//                currentState = .Jump

                self.setScale(normalSize)
                if isJumping == false {

                    isJumping = true
                    self.physicsBody?.applyImpulse(cgVector)
                    self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Jump.sprites(soldierSelected), timePerFrame: 0.07), count: 1), completion: { () -> Void in

                        dispatch_after(1, dispatch_get_main_queue()) {
//                          self.runAction(SKAction.moveTo(CGPointMake(self.position.x - 200, self.position.y), duration:0.5))
                            self.isJumping = false
                        }
                    })
            }

            case .Duck:
//                currentState = .Duck

                self.setScale(duckingSize)
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Duck.sprites(soldierSelected), timePerFrame: 0.07), count: 1), completion: { () -> Void in
                    self.setScale(self.normalSize)
                        }
                    )

            case .Dead:
//                currentState = .Dead
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Dead.sprites(soldierSelected), timePerFrame: 0.07), count: 1))

        }
    }



    func update() {
        // update when told by the GameScene class

    }
}
