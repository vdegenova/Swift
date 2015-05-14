//
//  GameScene.swift
//  Project23
//
//  Created by Vinny DeGenova on 5/13/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var starField: SKEmitterNode!
    var player: SKNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        backgroundColor = UIColor.blackColor()
        let starFieldPath = NSBundle.mainBundle().pathForResource("Starfield", ofType: "sks")
        starField = NSKeyedUnarchiver.unarchiveObjectWithFile(starFieldPath!) as! SKEmitterNode
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
