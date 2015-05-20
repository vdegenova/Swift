//
//  GameScene.swift
//  Project26
//
//  Created by Vinny DeGenova on 5/17/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import CoreMotion
import SpriteKit


enum CollisionTypes: UInt32 {
    case Player = 1
    case Wall = 2
    case Star = 4
    case Vortex = 8
    case Finish = 16
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var viewController: GameViewController!
    var motionManager: CMMotionManager!
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var scoreLabel: SKLabelNode!
    var gameOver = false
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        addChild(background)
    
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        loadlevel()
        createPlayer()
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .Left
        addChild(scoreLabel)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA!.node == player {
            playerCollideWithNode(contact.bodyB!.node)
        } else if contact.bodyB!.node == player {
            playerCollideWithNode(contact.bodyA!.node)
        }
    }
    
    func playerCollideWithNode(node: SKNode!) {
        if node.name == "vortex" {
            node.physicsBody?.dynamic = false
            gameOver = true
            --score
            
            let move = SKAction.moveTo(node.position, duration: 0.25)
            let scale = SKAction.scaleTo(0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.runAction(sequence) { [unowned self] in
                self.createPlayer()
                self.gameOver = false
            }
            
        } else if node.name == "star" {
            node.removeFromParent()
            ++score
            
        } else if node.name == "finish" {
            let ac = UIAlertController(title: "You win!", message: nil, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Next Level", style: UIAlertActionStyle.Default, handler: nil))
            
            viewController.presentViewController(ac, animated: true, completion: nil)
            //next level
            
            createPlayer()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(self)
        
        lastTouchPosition = location
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(self)
        
        lastTouchPosition = location
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        lastTouchPosition = nil
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        lastTouchPosition = nil
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if !gameOver {
            
            #if (arch(i386) || arch(x86_64)) //if in the simulator
                if let currentTouch = lastTouchPosition {
                    let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                    physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
                }
                #else //if we are on a device
                if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.y * -50, dy: accelerometerData.x * 50)
                }
            #endif
        }

    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.categoryBitMask = CollisionTypes.Player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.Star.rawValue | CollisionTypes.Vortex.rawValue | CollisionTypes.Finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.Wall.rawValue
        
        addChild(player)
        
    }
    
    func loadlevel() {
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt") {
            if let levelString = NSString(contentsOfFile: levelPath, usedEncoding: nil, error: nil) {
                let level = levelString.componentsSeparatedByString("\n") as! [String]
                
                for (row, line) in enumerate(reverse(level)) {
                    for (column, letter) in enumerate(line) {
                        let position = CGPoint(x: (column * 64) + 32, y: (row * 64) + 32)
                        
                        if letter == "x" {
                            //load wall
                            let node = SKSpriteNode(imageNamed: "block")
                            node.position = position
                            
                            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
                            node.physicsBody?.categoryBitMask = CollisionTypes.Wall.rawValue
                            node.physicsBody?.dynamic = false
                            
                            addChild(node)
                        } else if letter == "s" {
                            //load star
                            let node = SKSpriteNode(imageNamed: "star")
                            node.position = position
                            node.name = "star"
                            
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody?.dynamic = false
                            node.physicsBody?.categoryBitMask = CollisionTypes.Star.rawValue
                            node.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
                            node.physicsBody?.collisionBitMask = 0
                            
                            addChild(node)
                        } else if letter == "v" {
                            //load vortex
                            let node = SKSpriteNode(imageNamed: "vortex")
                            node.position = position
                            node.name = "vortex"
                            
                            node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1)))
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 3)
                            node.physicsBody?.categoryBitMask = CollisionTypes.Vortex.rawValue
                            node.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue //get notified when in contact with player
                            node.physicsBody?.collisionBitMask = 0
                            node.physicsBody?.dynamic = false
                            
                            addChild(node)
                            
                        } else if letter == "f" {
                            //load finish
                            let node = SKSpriteNode(imageNamed: "finish")
                            node.position = position
                            node.name = "finish"
                            
                            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                            node.physicsBody?.categoryBitMask = CollisionTypes.Finish.rawValue
                            node.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
                            node.physicsBody?.collisionBitMask = 0
                            node.physicsBody?.dynamic = false
                            
                            addChild(node)
                        }
                    }
                }
            }
        }
        
    }
}
