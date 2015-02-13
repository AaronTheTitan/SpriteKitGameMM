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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    enum SoldierStates:Int {

        case Idle
        case Walk
        case Run
        case Jump
        case Crouch
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

            case Crouch:
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
    }

    func stepState() {
        switch currentState {

            case .Idle:
                currentState = .Idle
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Idle.sprites(), timePerFrame: 0.07)))

            case .Walk:
                currentState = .Walk
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Walk.sprites(), timePerFrame: 0.07)))

            case .Run:
                currentState = .Run
                self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(SoldierStates.Run.sprites(), timePerFrame: 0.04)))

            case .Jump:
                currentState = .Jump
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Jump.sprites(), timePerFrame: 0.07), count: 1))

            case .Crouch:
                currentState = .Crouch
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Crouch.sprites(), timePerFrame: 0.07), count: 1))

            case .Dead:
                currentState = .Dead
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.Dead.sprites(), timePerFrame: 0.07), count: 1))

            case .RunShoot:
                currentState = .RunShoot
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.RunShoot.sprites(), timePerFrame: 0.05), count: 1))

            case .WalkShoot:
                currentState = .WalkShoot
                self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(SoldierStates.WalkShoot.sprites(), timePerFrame: 0.07), count: 1))

        }
    }

    func update() {
        // update when told by the GameScene class
        
        if currentState != .Idle {
            //run, croch, etc
//            self.position = CGPointMake(self.position.x + 5, self.position.y)
        }

        if currentState == .Jump {
           // self.physicsBody?.applyImpulse(CGVectorMake(0, 40))
//            [self.physicsBody applyImpulse:CGVectorMake(0, 40)];
            self.physicsBody?.applyImpulse(CGVectorMake(0,40))

        }

        if currentState == .RunShoot {

        }
    }
}
