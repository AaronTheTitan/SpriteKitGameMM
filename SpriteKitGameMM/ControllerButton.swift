//
//  ControllerButton.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/11/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit

class ControllerButton: UIButton {



    @IBAction func buttonTapJump(sender: UIButton) {
        println("JUMP")

//        soldierNode?.setCurrentState(Soldier.SoldierStates.Jump)
//        soldierNode?.stepState()
    }

    @IBAction func buttonTapDuck(sender: UIButton) {
        println("DUCK")
//        soldierNode?.setCurrentState(Soldier.SoldierStates.Crouch)
//        soldierNode?.stepState()
    }

}