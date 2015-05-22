//
//  ViewController.swift
//  Project28
//
//  Created by Vinny DeGenova on 5/21/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var secret: UITextView!
    var navigationBarHeight: CGFloat?

    @IBAction func authenticateUser(sender: UIButton) {
        var context = LAContext()
        var error: NSError?
        
        if true {//if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) { //commented out for testing in simulator
            var reason = "Identify yourself!"
            
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success: Bool, authenticationError: NSError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if true {//success { //commented out for testing in simulator
                        self.unlockSecretMessage()
                    } else {
                        if let error = authenticationError {
                            if error.code == LAError.UserFallback.rawValue {
                                let ac = UIAlertController(title: "Passcode? Ha!", message: "It's Touch ID or nothing – sorry!", preferredStyle: .Alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                                self.presentViewController(ac, animated: true, completion: nil)
                                return
                            }
                        }
                        
                        let ac = UIAlertController(title: "Authentication failed", message: "Your fingerprint could not be verified; please try again.", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                    }
                }
            }
        } else {
            // no Touch ID
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(ac, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: "saveSecretMessage", name: UIApplicationWillResignActiveNotification, object: nil)
        navigationBarHeight = self.navigationController?.navigationBar.frame.height
        secret.contentInset = UIEdgeInsets(top: navigationBarHeight!, left: 0, bottom: 0, right: 0)
        title = "Nothing to see here"
    }
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            secret.contentInset = UIEdgeInsetsZero
        } else {
            secret.contentInset = UIEdgeInsets(top: navigationBarHeight!, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.hidden = false
        title = "Secret stuff!"
        
        if let text = KeychainWrapper.stringForKey("SecretMessage") {
            secret.text = text
            secret.contentInset = UIEdgeInsets(top: navigationBarHeight!, left: 0, bottom: 0, right: 0)
        }
    }
    
    func saveSecretMessage() {
        if !secret.hidden {
            KeychainWrapper.setString(secret.text, forKey: "SecretMessage")
            secret.resignFirstResponder()
            secret.hidden = true
            title = "Nothing to see here"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

