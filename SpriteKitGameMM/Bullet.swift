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

//    var currentState = WeaponStates.Fire
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//
//    enum WeaponStates:Int {
//
//        case Fire
//
//        func sprites() -> [SKTexture] {
//            switch self {
//
//            case .Fire:
//                return (0...9).map{ SKTexture(imageNamed: "YellowMuzzle__00\($0)")! }
//
//            }
//        }
//    }
//
//    func setCurrentState(currentStateEntry: WeaponStates) {
//        currentState = currentStateEntry
//    }
//
//
//    init(imageNamed: String) {
//
//        let imageTexture = SKTexture(imageNamed: imageNamed)
//        super.init(texture: imageTexture, color: nil, size: imageTexture.size())
//    }
//
//    func weaponState() {
//        switch currentState {
//
//        case .Fire:
//            currentState = .Fire
//            self.runAction(SKAction.repeatAction(SKAction.animateWithTextures(WeaponStates.Fire.sprites(), timePerFrame: 0.07), count: 1))
//
////            self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(WeaponStates.Fire.sprites(), timePerFrame: 0.07)))
//
//        }
//    }
//
//    func update() {
//        // update when told by the GameScene class
//        if currentState != .Fire{
//            //run, croch, etc
//            //            self.position = CGPointMake(self.position.x + 5, self.position.y)
//        }
//
//    }
}
