//
//  GameScene.swift
//  Project14
//
//  Created by Vinny DeGenova on 4/30/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "ChalkDuster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .Left
        gameScore.fontSize = 48
        addChild(gameScore)

        for i in 0 ..< 5 { createSlotAt(CGPoint(x: 100 + (170*i), y: 410)) }
        for i in 0 ..< 4 { createSlotAt(CGPoint(x: 180 + (170*i), y: 320)) }
        for i in 0 ..< 5 { createSlotAt(CGPoint(x: 100 + (170*i), y: 230)) }
        for i in 0 ..< 4 { createSlotAt(CGPoint(x: 180 + (170*i), y: 140)) }
    }
    
    func createSlotAt(pos: CGPoint) {
        let slot = WhackSlot()
        slot.configureAtPosition(pos)
        addChild(slot)
        slots.append(slot)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
