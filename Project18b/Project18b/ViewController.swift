//
//  ViewController.swift
//  Project18b
//
//  Created by Vinny DeGenova on 5/9/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for i in 1 ... 100 {
            println("Got number \(i)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

