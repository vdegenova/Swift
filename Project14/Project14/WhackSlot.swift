//
//  WhackSlot.swift
//  Project14
//
//  Created by Vinny DeGenova on 4/30/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    func configureAtPosition(pos: CGPoint) {
        position = pos
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
    }
}
