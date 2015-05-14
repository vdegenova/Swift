//
//  GameScene.swift
//  Project23
//
//  Created by Vinny DeGenova on 5/13/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: NSTimer!
    var gameOver = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        backgroundColor = UIColor.blackColor()
        let starFieldPath = NSBundle.mainBundle().pathForResource("Starfield", ofType: "sks")
        starField = NSKeyedUnarchiver.unarchiveObjectWithFile(starFieldPath!) as! SKEmitterNode
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size)
        player.physicsBody!.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .Left
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: "createEnemy", userInfo: nil, repeats: true)
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        var location = touch.locationInNode(self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func createEnemy(){
        possibleEnemies.shuffle()
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        sprite.position = CGPoint(x: 1200, y: RandomInt(min: 50, max: 736))
        
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0

    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let explosionPath = NSBundle.mainBundle().pathForResource("explosion", ofType: "sks")
        let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionPath!) as! SKEmitterNode
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        gameOver = true
        
        GameOver()
        
    }
    
    func GameOver() {
        gameTimer.invalidate()
        let ac = UIAlertController(title: "Game Over!", message: "Score: \(score)", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: restart))
        self.view!.window?.rootViewController?.presentViewController(ac, animated: true, completion: nil)
        
    }
    
    func restart(alert: UIAlertAction!) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture, size: player.size)
        player.physicsBody!.contactTestBitMask = 1
        addChild(player)
        
        
        score = 0
        gameOver = false
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.35, target: self, selector: "createEnemy", userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        for node in children as! [SKNode] {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !gameOver {
            ++score
        }
    }
}
