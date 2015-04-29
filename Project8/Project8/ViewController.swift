//
//  ViewController.swift
//  Project8
//
//  Created by Vinny DeGenova on 4/16/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score * 10)"
        }
    }
    var level = 1
    
    @IBAction func submitTapped(sender: UIButton) {
        if let solutionPosition = find(solutions, currentAnswer.text) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text!.componentsSeparatedByString("\n")
            splitAnswers[solutionPosition] = solutions[solutionPosition]
            answersLabel.text = join("\n", splitAnswers)
            
            currentAnswer.text = ""
            ++score
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "You win!", message: nil, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func clearTapped(sender: UIButton) {
        for btn in activatedButtons {
            btn.hidden = false
        }
        activatedButtons.removeAll()
        currentAnswer.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for subview in view.subviews {
            if subview.tag == 1001 {
                let btn = subview as UIButton
                letterButtons.append(btn)
                btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
            }
        }
        
        loadLevel()
    }
    
    func levelUp(action: UIAlertAction!) {
        ++level
        loadLevel()
        
        for btn in letterButtons {
            btn.hidden = false
        }
    }
    
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.hidden = true
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelPath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt") {
            if let levelContents = NSString(contentsOfFile: levelPath, usedEncoding: nil, error: nil) {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines.shuffle()
                
                for (index, line) in enumerate(lines as [String]) {
                    var parts = line.componentsSeparatedByString(":")
                    var answer = parts[0]
                    var clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(countElements(solutionWord)) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        //now configure buttons and labels
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterBits.shuffle()
        letterButtons.shuffle()
        
        if letterButtons.count == letterBits.count {
            for i in 0 ..< letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

