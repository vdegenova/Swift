//
//  GameScene.swift
//  Project14
//
//  Created by Vinny DeGenova on 4/30/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var popUpTime = 0.85
    var numRounds = 0
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
        
        runAfterDelay(1) { [unowned self] in
            self.createEnemy()
        }
    }
    
    func createEnemy() {
        ++numRounds
        
        if numRounds > 30 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            addChild(gameOver)
            
            return
        }
        popUpTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popUpTime)
        
        if RandomInt(min: 0, max: 12) > 4 { slots[1].show(hideTime: popUpTime) }
        if RandomInt(min: 0, max: 12) > 8 {	slots[2].show(hideTime: popUpTime) }
        if RandomInt(min: 0, max: 12) > 10 { slots[3].show(hideTime: popUpTime) }
        if RandomInt(min: 0, max: 12) > 11 { slots[4].show(hideTime: popUpTime)	}
        
        let minTime = popUpTime/2
        let maxTime = popUpTime*2
        
        runAfterDelay(RandomDouble(min: minTime, max: maxTime)) { [unowned self] in
            self.createEnemy()
        }
    }
    
    func createSlotAt(pos: CGPoint) {
        let slot = WhackSlot()
        slot.configureAtPosition(pos)
        addChild(slot)
        slots.append(slot)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.anyObject() as UITouch
        let location = touch.locationInNode(self)
        let nodes = nodesAtPoint(location) as [SKNode]
        
        for node in nodes {
            if node.name == "charFriend" {
                //shouldnt have whacked
                let whackSlot = node.parent!.parent as WhackSlot
                if !whackSlot.visible { continue }
                if whackSlot.isHit { continue }
                
                whackSlot.hit()
                score -= 5
                
                runAction(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            }
            else if node.name == "charEnemy" {
                //should whack this one
                let whackSlot = node.parent!.parent as WhackSlot
                if !whackSlot.visible { continue }
                if whackSlot.isHit { continue }
                
                whackSlot.charNode.xScale = 0.5
                whackSlot.charNode.yScale = 0.5
                
                whackSlot.hit()
                ++score
                
                runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
