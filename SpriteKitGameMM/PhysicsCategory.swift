//
//  PhysicsCategory.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/18/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation

// MARK: - PHYSICS CATEGORY STRUCT
struct PhysicsCategory {
    static let None                : UInt32 = 0
    static let SoldierCategory     : UInt32 = 0b1       //1
    static let ObstructionCategory : UInt32 = 0b10      //2
    static let Edge                : UInt32 = 0b100     //3
    //        static let PowerupCategory     : UInt32 = 0b10000   //5
    static let SuperPowerCategory  : UInt32 = 0b1000  //6
    static let BombCategory        : UInt32 = 0b10000 //7
    static let WarheadCategory     : UInt32 = 0b100000 //8

}

