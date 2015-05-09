//
//  GameScene.swift
//  Project20
//
//  Created by Vinny DeGenova on 5/9/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameTimer: NSTimer!
    var fireworks = [SKNode]()
    
    var leftEdge = -22
    var rightEdge = 1024 + 22
    var bottomEdge = -22
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    
        let background = SKSpriteNode(imageNamed: "background")
        background.blendMode = .Replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = 0
        
        addChild(background)
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "launchFireworks", userInfo: nil, repeats: true)
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.position = CGPoint(x: 120, y: 10)
        scoreLabel.text = "Score: 0"
        
        addChild(scoreLabel)
        
        //physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
        //physicsWorld.speed = 0.5

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        checkForTouches(touches)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        checkForTouches(touches)
    }
    
    func checkForTouches(touches: Set<NSObject>) {
        let touch = touches.first as! UITouch
        
        let location = touch.locationInNode(self)
        let nodes = nodesAtPoint(location) as! [SKNode]
        
        for node in nodes {
            if node.isKindOfClass(SKSpriteNode.self) {
                let sprite = node as! SKSpriteNode
                
                if sprite.name == "firework" {
                    for parent in fireworks {
                        let firework = parent.children[0] as! SKSpriteNode
                        
                        if firework.name == "selected" && firework.color != sprite.color {
                            firework.name = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                    
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                }
            }
        }
    }
    
    func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch RandomInt(min: 0, max: 3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
            
        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
            
        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
            
        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
            
        default:
            break
        }
    }
    
    func createFirework(#xMovement: CGFloat, x: Int, y: Int) {
        //create firework container node
        let node = SKSpriteNode()
        node.position = CGPoint(x: x, y: y)
        //node.physicsBody = SKPhysicsBody()
        //node.physicsBody!.dynamic = true
        
        //create firework node
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        node.addChild(firework)
        
        //color firework
        switch RandomInt(min: 0, max: 2) {
        case 0:
            firework.color = UIColor.cyanColor()
            firework.colorBlendFactor = 1
        case 1:
            firework.color = UIColor.redColor()
            firework.colorBlendFactor = 1
        case 2:
            firework.color = UIColor.greenColor()
            firework.colorBlendFactor = 1
        default:
            break
        }
        
        //create firework path
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: xMovement, y: 1000))
        
        //have container follow the path
        let move = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: true, speed: 200)
        node.runAction(move)
        
        //create firework sparks
        let particlePath = NSBundle.mainBundle().pathForResource("fuse", ofType: "sks")
        let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePath!) as! SKEmitterNode
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        //add to scene and fireworks array
        fireworks.append(node)
        addChild(node)
        
    }
    
    func explodeFirework(firework: SKNode) {
        let particlePath = NSBundle.mainBundle().pathForResource("explode", ofType: "sks")!
        let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePath) as! SKEmitterNode
        emitter.position = firework.position
        addChild(emitter)
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for var i = fireworks.count - 1; i >= 0; --i {
            let parent = fireworks[i]
            let firework = parent.children[0] as! SKSpriteNode
            
            if firework.name == "selected" {
                // destroy this firework!
                explodeFirework(parent)
                fireworks.removeAtIndex(i)
                
                ++numExploded
            }
        }
        
        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for var i = fireworks.count - 1; i >= 0; --i {
            let firework = fireworks[i]
            
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.removeAtIndex(i)
                firework.removeFromParent()
            }
        }
    }
}
