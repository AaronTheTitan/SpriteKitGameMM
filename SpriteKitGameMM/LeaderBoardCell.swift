//
//  LeaderBoardCell.swift
//  SpriteKitGameMM
//
//  Created by Aaron Bradley on 2/21/15.
//  Copyright (c) 2015 Aaron Bradley. All rights reserved.
//

import Foundation

class LeaderBoardCell: UITableViewCell {

    var ranking:String?
    var playerName:String?
    var playerScore:String?


    @IBOutlet var cellRanking: UILabel!



// name of cell identifier - leaderBoardCell




    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }




}
