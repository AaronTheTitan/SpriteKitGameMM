//
//  ScoreLabels.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/18/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation
import SpriteKit


class ScoreLabel: SKLabelNode {

    var labelScore:SKLabelNode!
    var highScoreLabel:SKLabelNode!

    var score: Int!
    var highScore:NSInteger?
    var totalScore:NSInteger?

    override init() {
        super.init()

        score = 0
        highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addScoring() {
        addScoreLabel()
        addHighScoreLabel()
    }

    func addScoreLabel(){
        labelScore = SKLabelNode(text: "Score: \(score)")
        labelScore.fontName = "Optima Bold"
        labelScore.fontSize = 24
        labelScore.zPosition = 4
//        labelScore.position = CGPointMake(20 + self.frame.size.width/2, self.frame.size.height - (120 + labelScore.frame.size.height/2))
//        labelScore.position = CGPointMake(20 + self.frame.size.width/2, self.frame.size.height - (120 + labelScore.frame.size.height/2))
//        labelScore.position = CGPointMake(20 + labelScore.frame.size.width/2, self.size.height - (120 + labelScore.frame.size.height/2))
        addChild(labelScore)

    }

    func addHighScoreLabel(){
        highScoreLabel = SKLabelNode(text: "Highscore: \(highScore!)")
        highScoreLabel.fontName = "Optima Bold"
        highScoreLabel.fontSize  = 24
        highScoreLabel.zPosition = 4
//        highScoreLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - (120 + labelScore.frame.size.height/2))
        addChild(highScoreLabel)
    }

}