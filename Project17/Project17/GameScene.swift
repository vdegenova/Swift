//
//  GameScene.swift
//  Project17
//
//  Created by Vinny DeGenova on 5/8/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import SpriteKit
import AVFoundation

enum SequenceType: Int {
    case OneNoBomb, One, TwoWithOneBomb, Two, Three, Four, Chain, FastChain
}

enum ForceBomb {
    case Never, Always, Default
}

class GameScene: SKScene {

    var gameScore: SKLabelNode!             //score label
    var score: Int = 0 {                    //current score
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var liveImages = [SKSpriteNode]()       //images denoting lives
    var lives = 3                           //number of lives
    
    var activeSliceBG: SKShapeNode!         //slice background
    var activeSliceFG: SKShapeNode!         //slice foreground
    
    var activeSlicePoints = [CGPoint]()     //slice points array
    var swooshSoundActive = false           //bool if swoosh is playing
    var bombSoundEffect: AVAudioPlayer!     //fuse sound effect
    
    var activeEnemies = [SKSpriteNode]()    //enemies currently in frame
    
    var popupTime = 0.9                     //time between destroyed enemy and new enemy
    var sequence: [SequenceType]!           //array denoting which sequence to generate
    var sequencePosition = 0                //where we are in the game
    var chainDelay = 3.0                    //how long to wait for new enemy in a chain
    var nextSequenceQueued = true           //true when all enemies destroyed so we can create more
    
    var gameEnded = false                   //to determine if game is over or not
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //create background
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        addChild(background)
        
        //set up physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        //create essential types
        createScore()
        createLives()
        createSlices()
        
        //create game sequence
        sequence = [.OneNoBomb, .OneNoBomb, .TwoWithOneBomb, .TwoWithOneBomb, .Three, .One, .Chain]
        
        //exclude 1st 2 cases from sequence as they are only for starting
        for i in 0 ... 1000 {
            var nextSequence = SequenceType(rawValue: RandomInt(min: 2, max: 7))!
            sequence.append(nextSequence)
        }
        
        //start sending enemies after 2 seconds!
        runAfterDelay(2) { [unowned self] in
            self.tossEnemies()
        }

    }
    
    func createEnemy(forcebomb: ForceBomb = .Default) {
        var enemy: SKSpriteNode
        
        var enemyType = RandomInt(min: 0, max: 6)
        
        if forcebomb == .Never {
            //if we dont want a bomb
            enemyType = 1
        } else if forcebomb == .Always {
            //if we always want a bomb
            enemyType = 0
        }
        
        if enemyType == 0 {
            //bomb code
            
            //create bomb/fuse container
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            //get the bomb image
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            //stop bomb sound effect if playing
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
            
            //play bomb sound effect
            let path = NSBundle.mainBundle().pathForResource("sliceBombFuse.caf", ofType: nil)!
            let url = NSURL(fileURLWithPath: path)
            let sound = AVAudioPlayer(contentsOfURL: url, error: nil)
            bombSoundEffect = sound
            sound.play()
            
            //create fuse emitter
            let particlePath = NSBundle.mainBundle().pathForResource("sliceFuse", ofType: "sks")!
            let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(particlePath) as! SKEmitterNode
            emitter.position = CGPoint(x: 76, y: 64)
            enemy.addChild(emitter)
            
        }
        else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            runAction(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        //position code
        
        //give enemy random position along bottom of screen
        let randomPosition = CGPoint(x: RandomInt(min: 64, max: 960), y: -128)
        enemy.position = randomPosition
        
        //create random angular velocity
        let randomAngularVelocity = CGFloat(RandomInt(min: -6, max: 6)) / 2.0
        var randomXVelocity = 0
        
        //create random x velocity
        if position.x < 256 {
            randomXVelocity = RandomInt(min: 8, max: 15)
        } else if randomPosition.x < 512 {
            randomXVelocity = RandomInt(min: 3, max: 5)
        } else if randomPosition.x < 768 {
            randomXVelocity = -RandomInt(min: 3, max: 5)
        } else {
            randomXVelocity = -RandomInt(min: 8, max: 15)
        }
        
        //create random y velocity
        let randomYVelocity = RandomInt(min: 24, max: 32)
        
        //creat enemy's physics body
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody!.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody!.angularVelocity = randomAngularVelocity
        enemy.physicsBody!.collisionBitMask = 0 //no collisions
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func createScore() {
        //create score label
        gameScore = SKLabelNode(fontNamed: "ChalkDuster")
        gameScore.text = "Score: 0"
        gameScore.horizontalAlignmentMode = .Left
        gameScore.fontSize = 48
        
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
    }
    
    func createLives() {
        //creates lives for player to see
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + i*70), y: 720)
            addChild(spriteNode)
            
            liveImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        //creates slice effect default values
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 2
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.whiteColor()
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    func redrawActiveSlice() {
        
        //need at leats 2 points to make a slice
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        //max slice number so they do not become excessively long
        while activeSlicePoints.count >  12 {
            activeSlicePoints.removeAtIndex(0)
        }
        
        //create path and add initial point
        var path = UIBezierPath()
        path.moveToPoint(activeSlicePoints[0])
        
        //loop through points to create path
        for var i = 1; i < activeSlicePoints.count; i++ {
            path.addLineToPoint(activeSlicePoints[i])
        }
        
        //set slice path attribute to created path
        activeSliceBG.path = path.CGPath
        activeSliceFG.path = path.CGPath
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        
        //clear all old slice points
        activeSlicePoints.removeAll(keepCapacity: true)
        
        //get the first touch point, add it to the slice point array
        let touch = touches.first! as! UITouch
        let location = touch.locationInNode(self)
        activeSlicePoints.append(location)
        
        //redraw the new slice
        redrawActiveSlice()
        
        //remove the sound effect from old slices
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        //make the slices visible
        activeSliceFG.alpha = 1
        activeSliceBG.alpha = 1
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if gameEnded { //dont allow game to be played if over
            return
        }
        
        //get the new location and add it to the slice points array
        let touch = touches.first! as! UITouch
        let location = touch.locationInNode(self)
        
        activeSlicePoints.append(location)
        
        //redraw it
        redrawActiveSlice()
        
        //play the swoosh sound if one is not playing
        if !swooshSoundActive {
            playSwooshSound()
        }
        
        let nodes = nodesAtPoint(location) as! [SKNode]
        
        for node in nodes {
            if node.name == "enemy" {
                //destroy penguin
                
                //create particle effect over penguin
                let explosionPath = NSBundle.mainBundle().pathForResource("sliceHitEnemy", ofType: "sks")!
                let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionPath) as! SKEmitterNode
                emitter.position = node.position
                addChild(emitter)
                
                //clear node name so it cannot be swiped again
                node.name = ""
                
                //disable dynamic physics body so it doesnt fall anymore
                node.physicsBody!.dynamic = false
                
                //scale out and fase out penguin simultaneously
                let scaleOut = SKAction.scaleTo(0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOutWithDuration(0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                //after scaling and fading, remove the node
                //sequences are one after another, groups are simultaneous actions
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.runAction(seq)
                
                //add one to player score
                ++score
                
                //remove node from active enemies array
                let index = find(activeEnemies, node as! SKSpriteNode)!
                activeEnemies.removeAtIndex(index)
                
                //play sound to alert user
                runAction(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                //detroy bomb
                
                //create particle effect over bomb
                let explosionPath = NSBundle.mainBundle().pathForResource("sliceHitBomb", ofType: "sks")!
                let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionPath) as! SKEmitterNode
                emitter.position = node.parent!.position
                addChild(emitter)
                
                //clear node name so it cant be swiped again
                node.name = ""
                node.parent!.physicsBody!.dynamic = false
                
                //scale out and fade out
                let scaleOut = SKAction.scaleTo(0.001, duration:0.2)
                let fadeOut = SKAction.fadeOutWithDuration(0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                //remove node from scene
                let seq = SKAction.sequence([group, SKAction.removeFromParent()])
                node.parent!.runAction(seq)
                
                //remove from active enemies array
                let index = find(activeEnemies, node.parent as! SKSpriteNode)!
                activeEnemies.removeAtIndex(index)
                
                //play sound
                runAction(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                
                //Bombs are automatic game over so end the game
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        //fade out the slices!
        activeSliceBG.runAction(SKAction.fadeOutWithDuration(0.25))
        activeSliceFG.runAction(SKAction.fadeOutWithDuration(0.25))
    }
    
    func playSwooshSound() {
        swooshSoundActive = true
        //choose sound to play
        var randomNumber = RandomInt(min: 1, max: 3)
        var soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        //play sound, closure called after completion
        runAction(swooshSound) { [unowned self] in
            self.swooshSoundActive = false
        }
    }
    
    func tossEnemies() {
        //function to toss enemies onto screen
        
        if gameEnded { //prevent game play if it is over
            return
        }
        
        //decrease popup time, chain delay, and increase gravity each time to make it harder
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        //get the current sequence type
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .OneNoBomb:
            createEnemy(forcebomb: .Never)
            
        case .One:
            createEnemy()
            
        case .TwoWithOneBomb:
            createEnemy(forcebomb: .Never)
            createEnemy(forcebomb: .Always)
            
        case .Two:
            createEnemy()
            createEnemy()
            
        case .Three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .Four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .Chain:
            createEnemy()
            
            runAfterDelay(chainDelay / 5.0) { [unowned self] in self.createEnemy() }
            runAfterDelay(chainDelay / 5.0 * 2) { [unowned self] in self.createEnemy() }
            runAfterDelay(chainDelay / 5.0 * 3) { [unowned self] in self.createEnemy() }
            runAfterDelay(chainDelay / 5.0 * 4) { [unowned self] in self.createEnemy() }
            
        case .FastChain:
            createEnemy()
            
            runAfterDelay(chainDelay / 10.0) { [unowned self] in self.createEnemy() }
            runAfterDelay(chainDelay / 10.0 * 2) { [unowned self] in self.createEnemy() }
            runAfterDelay(chainDelay / 10.0 * 3) { [unowned self] in self.createEnemy() }
            runAfterDelay(chainDelay / 10.0 * 4) { [unowned self] in self.createEnemy() }
        }
        
        
        ++sequencePosition
        
        nextSequenceQueued = false
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var bombCount = 0
        
        //see if we have any bombs in the frame
        for node in activeEnemies {
            if node.name == "bombContainer" {
                ++bombCount
                break
            }
        }
        
        //if we dont, stop the fuse sound!
        if bombCount == 0 {
            if bombSoundEffect != nil {
                bombSoundEffect.stop()
                bombSoundEffect = nil
            }
        }
        
        
        //see if we have enemies that need to be removed
        if activeEnemies.count > 0 {
            for node in activeEnemies {
                
                //if it is low enough to be removes
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    //clear node name and take necessary actions
                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()
                    
                        node.removeFromParent()
                        if let pos = find(activeEnemies, node) {
                            activeEnemies.removeAtIndex(pos)
                        }
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        
                        if let index = find(activeEnemies, node) {
                            activeEnemies.removeAtIndex(index)
                        }
                    }
                   
                }
                
            }
        } else{
            //otherwise, toss more enemies!
            if !nextSequenceQueued {
                runAfterDelay(popupTime) { [unowned self] in
                    self.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }
    }
    
    func subtractLife() {
        //subtract a life
        --lives
        
        //play 'wrong' sound
        runAction(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        //get correct life image object
        var life: SKSpriteNode
        
        if lives == 2 {
            life = liveImages[0]
        } else if lives == 1 {
            life = liveImages[1]
        } else {
            life = liveImages[2]
            endGame(triggeredByBomb: false)
        }
        
        //animate life being crossed off
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.runAction(SKAction.scaleTo(1, duration: 0.1))
    }
    
    func endGame(#triggeredByBomb: Bool) {
        
        if gameEnded { //if the game is already over...
            return
        }
        
        //end the game and freeze everything
        gameEnded = true
        physicsWorld.speed = 0
        userInteractionEnabled = false
        
        //stop any sounds
        if bombSoundEffect != nil {
            bombSoundEffect.stop()
            bombSoundEffect = nil
        }
        
        //cross off all the lives
        if triggeredByBomb {
            liveImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            liveImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            liveImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
    }
    
} //end of class
