//
//  GameViewController.swift
//  Project29
//
//  Created by Vinny DeGenova on 5/21/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    var currentGame: GameScene!
    
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    @IBAction func angleChanged(sender: AnyObject!) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBAction func velocityChanged(sender: AnyObject!) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBOutlet weak var playerNumber: UILabel!
    
    @IBOutlet weak var launchButton: UIButton!
    @IBAction func launch(sender: UIButton) {
        angleSlider.hidden = true
        angleLabel.hidden = true
        
        velocitySlider.hidden = true
        velocityLabel.hidden = true
        
        launchButton.hidden = true
        
        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayerNumber(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.hidden = false
        angleLabel.hidden = false
        
        velocitySlider.hidden = false
        velocityLabel.hidden = false
        
        launchButton.hidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        angleChanged(nil)
        velocityChanged(nil)
        
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            currentGame = scene
            scene.viewController = self
        }
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
