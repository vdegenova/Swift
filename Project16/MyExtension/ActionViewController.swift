//
//  ActionViewController.swift
//  MyExtension
//
//  Created by Vinny DeGenova on 5/6/15.
//  Copyright (c) 2015 Vinny DeGenova. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "adjustForKeyboard:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            //input items is array of content from parent app to extension
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil) { [unowned self] (dict, error) in
                    
                    //do stuff!
                    let itemDictionary = dict as! NSDictionary
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    
                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.title = self.pageTitle
                    }
                }
            }
        }
    
    }
    
    func adjustForKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        if notification.name == UIKeyboardWillHideNotification {
            textView.contentInset = UIEdgeInsetsZero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        let item = NSExtensionItem()
        let webDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": textView.text]]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]

        
        extensionContext!.completeRequestReturningItems([item], completionHandler: nil)    }

}
