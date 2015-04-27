//
//  ShareViewController.swift
//  ShareToADN
//
//  Created by Dominik Hauser on 26/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import KeychainAccess
import PostToADN

let kSuiteName = "group.de.dasdom.posteruserdefaults"
let kActiveAccountNameKey = "kActiveAccountNameKey"
let kAccountNameArrayKey = "kAccountNameArrayKey"

class ShareViewController: NSViewController {

    var urlToShare: NSURL?
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var linkLabel: NSTextField!
    
    @IBOutlet weak var accountPopUpButton: NSPopUpButton!
    
    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()
    
        let items = extensionContext?.inputItems
        var itemProvider: NSItemProvider?
        
        let userDefaults = NSUserDefaults(suiteName: kSuiteName)
        if let usernameArray = userDefaults?.arrayForKey(kAccountNameArrayKey) as? [String] {
            for username in usernameArray {
                accountPopUpButton.addItemWithTitle(username)
            }
        }
        
        // Insert code here to customize the view
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
//            NSLog("Attachments = %@", attachments)
            
            for attachment in attachments {
                itemProvider = attachment as? NSItemProvider
                
                let imageType = kUTTypeImage as NSString as String
                let urlType = kUTTypeURL as NSString  as String
                
                if itemProvider?.hasItemConformingToTypeIdentifier(urlType) == true {
                    itemProvider?.loadItemForTypeIdentifier(urlType, options: nil) { (item, error) -> Void in
                        if error == nil {
                            if let url = item as? NSURL {
                                self.urlToShare = url
                                self.linkLabel.stringValue = url.absoluteString!
                                println("url: \(url)")
                            }
                        }
                    }
//                } else if itemProvider?.hasItemConformingToTypeIdentifier(imageType) == true {
//                    itemProvider?.loadItemForTypeIdentifier(imageType, options: nil) { (item, error) -> Void in
//                        if error == nil {
//                            println("item: \(item)")
//                            if let url = item as? NSURL {
//                                if let imageData = NSData(contentsOfURL: url) {
//                                    self.imageToShare = UIImage(data: imageData)
//                                }
//                            }
//                        }
//                    }
                }
            }
        } else {
            NSLog("No Attachments")
        }
    }

    @IBAction func send(sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        // Complete implementation by setting the appropriate value on the output item
        
        let text = textView.string!
        
        var linkLocation = 0
        var linkLength = count(text)
        var postString = String()
        var index = 0
        for char in text {
            if char == "[" {
                linkLocation = index
            } else if char == "]" {
                linkLength = index - linkLocation - 1
            } else {
                postString.append(char)
            }
            ++index
        }
        
        let linkDict = ["url" : urlToShare!.absoluteString!, "pos": "\(linkLocation)", "len": "\(linkLength)"]
        let linksArray: [[String:String]] = [linkDict]
        
        let username = accountPopUpButton.titleOfSelectedItem
        
        let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username!)")
        let adnApiCommunicator = ADNAPICommunicator()
        adnApiCommunicator.postText(text, linksArray: linksArray, accessToken: accessToken!, image: nil) { () -> () in
            let outputItems = [outputItem]
            self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
        }
}

    @IBAction func cancel(sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequestWithError(cancelError)
    }

}
