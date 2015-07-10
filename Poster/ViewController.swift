//
//  ViewController.swift
//  Poster
//
//  Created by dasdom on 12.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import ADN
import KeychainAccess
import Quartz
import Accounts
import Social

let DidLoginOrLogoutNotification = "DidLoginOrLogoutNotification"

class ViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet var textView: NSTextView!
    var accessToken: String?
    var username: String?
//    var image: NSImage?
    
    @IBOutlet weak var characterCountLabel: NSTextField!
    @IBOutlet weak var postButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var avatarImageView: NSImageView!
    @IBOutlet weak var postImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var postImageView: NSImageView!
    
    var accountStore: ACAccountStore?
    var activeAccountIdentifier: String?
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginOrLogout:", name: DidLoginOrLogoutNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "crossPostStateChanged:", name: kCrossPostStateChangedNotification, object: nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateView()
        updatePostButton()
        accountStore = ACAccountStore()
        
        postImageConstraint.constant = 0
    }
    
    func updateView() {
        if accessToken == nil {
            let userDefaults = NSUserDefaults(suiteName: kSuiteName)
            if let username = userDefaults?.stringForKey(kActiveAccountNameKey) {
                accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)")
            }
        }
        
        if let accessToken = accessToken {
            let adnApiCommunicator = ADNAPICommunicator()
            adnApiCommunicator.avatarWithAccessToken(accessToken, completion: { (image) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.avatarImageView.image = image
                    self.textView.string = ""
                })
            })
        } else {
            self.avatarImageView.image = nil
            self.textView.string = "Please log in."
        }
    }
    
    func updatePostButton() {
        activeAccountIdentifier = NSUserDefaults.standardUserDefaults().stringForKey(kActiveTwitterAccountIdKey)
        if activeAccountIdentifier == nil {
            postButton.title = "Post"
        } else {
            postButton.title = "Crosspost"
        }
    }
    
    func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String) -> Bool {
        let numberOfCharacters = count(textView.string!) - affectedCharRange.length + count(replacementString)
        characterCountLabel.stringValue = "\(256-numberOfCharacters)"
        return true
    }
    
    @IBAction func post(sender: NSButton) {
        
        println("post")
        
        if accessToken == nil {
            let userDefaults = NSUserDefaults(suiteName: kSuiteName)
            if let username = userDefaults?.stringForKey(kActiveAccountNameKey) {
                accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)")
            }
        }
        
        let alertInfo: (message: String, info: String)?
        if accessToken == nil {
            println("no accessToken")
            alertInfo = ("Please log in", "You have to log into App.net via the Login button to post ot App.net")
        } else if count(textView.string!) > 256 {
            alertInfo = ("Text to long", "The text is to long to be posted on App.net.")
        } else if count(textView.string!) < 1 {
            alertInfo = ("Text to short", "Please insert at least one character.")
        } else {
            alertInfo = nil
        }
        
        if let alertInfo = alertInfo {
            let alert = NSAlert()
            alert.messageText = alertInfo.message
            alert.informativeText = alertInfo.info
            alert.runModal()
            return
        }
        
        let linkExtractor = LinkExtractor()
        let (postText, linksArray) = linkExtractor.extractLinks(textView.string!)
        
        let adnApiCommunicator = ADNAPICommunicator()
        statusLabel.stringValue = "Posting to App.net"
        postButton.enabled = false
        adnApiCommunicator.postText(postText, linksArray: linksArray, accessToken: accessToken!, image: postImageView.image) { () -> () in
            
            if self.activeAccountIdentifier != nil {
                self.statusLabel.stringValue = "Tweeting to Twitter"
                self.tweetText(postText, linksArray: linksArray, accountIdentifier: self.activeAccountIdentifier!, image: self.postImageView.image, completion: { () -> () in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.resetView()
                    });
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.resetView()
                });
            }
            
        }
        
    }
    
    func resetView() {
        textView.string = ""
//        image = nil
        postImageView.image = nil
        postImageConstraint.constant = 0
        statusLabel.stringValue = ""
        postButton.enabled = true
    }
    
    @IBAction func changePicture(sender: AnyObject) {
//        IKPictureTaker().beginPictureTakerSheetForWindow(self.view.window, withDelegate: self, didEndSelector: "pictureTakerDidEnd:returnCode:contextInfo:", contextInfo: nil)
//        IKPictureTaker().popUpRecentsMenuForView(self.view, withDelegate: self, didEndSelector: "pictureTakerDidEnd:returnCode:contextInfo:", contextInfo: nil)
      
      let openPanel = NSOpenPanel()
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
      let dirURL = NSURL(fileURLWithPath: paths.first as! String)
      openPanel.directoryURL = dirURL
      openPanel.canChooseFiles = true
      openPanel.allowsMultipleSelection = false
      
      if (openPanel.runModal() == NSModalResponseOK) {
        let files = openPanel.URLs
        println("files \(files)")
        
        let image = NSImage(contentsOfURL: files.first as! NSURL)
        postImageView.image = image
        postImageConstraint.constant = 100
      }
    }
    
    func pictureTakerDidEnd(picker: IKPictureTaker, returnCode: NSInteger, contextInfo: UnsafePointer<Void>) {
        let image = picker.outputImage()
        
        if image != nil && returnCode == NSModalResponseOK {
            postImageView.image = image
            postImageConstraint.constant = 100
//            self.image = image
        }
    }
    
    @IBAction func imageAction(sender: NSImageView) {
        view.window?.makeFirstResponder(textView)
        postImageView.image = nil
        postImageConstraint.constant = 0
    }
}

// MARK: - Notifications
extension ViewController {
    func didLoginOrLogout(sender: NSNotification) {
        accessToken = nil
        updateView()
    }
    
    func crossPostStateChanged(sender: NSNotification) {
        activeAccountIdentifier = nil
        updatePostButton()
    }
}

// MARK: - Twitter
extension ViewController {
    func tweetText(text: String, linksArray: [[String:String]], accountIdentifier: String, image: NSImage?, completion: () -> ()) {
        
        var (tweetOne, tweetTwo) = tweetsFromText(text, linksArray: linksArray)
        
        println("postTextPartOne: \(tweetOne)")
        println("postTextPartTwo: \(tweetTwo)")
        
        var urlString = "https://api.twitter.com/1.1/statuses/update.json"
        if postImageView.image != nil {
            urlString = "https://api.twitter.com/1.1/statuses/update_with_media.json"
        }
        
        let parameters = ["status" : tweetOne]
        let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: urlString), parameters: parameters)
        
        if let image = image {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy_MM_dd'T'HH_mm_ss'Z'"
            let imageName = "\(dateFormatter.stringFromDate(NSDate()))" + "jpg"
            
           let imageData = image.jpegDataWithCompressionFactor(0.5)
            tweetRequest.addMultipartData(imageData, withName: "media", type: "image/jpg", filename: imageName)
        }
        
        let account = accountStore?.accountWithIdentifier(accountIdentifier)
        tweetRequest.account = account
        tweetRequest.performRequestWithHandler { (tweetData, tweetResponse, tweetError) in
            println("error: \(tweetError)")
            println("tweetResponse: \(tweetResponse)")
            
            if tweetResponse.statusCode != 200 {
                dispatch_async(dispatch_get_main_queue(), {
//
//                    let alertMessage = "Tweeting didn't work."
//                    let alert = UIAlertController(title: "There was an error", message: alertMessage, preferredStyle: .Alert)
//                    let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//                        println("OK")
//                    })
//                    alert.addAction(okAction)
//                    
//                    self.presentViewController(alert, animated: true, completion: nil)
//                    
                    completion()
                })
                return
            }
            
            if tweetTwo != "" {
                let parameters = ["status" : tweetTwo]
                let tweetRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/update.json"), parameters: parameters)
                tweetRequest.account = account
                tweetRequest.performRequestWithHandler { (tweetData, tweetResponse, tweetError) in
                    println("error: \(tweetError)")
                    println("tweetResponse: \(tweetResponse)")
                    
                    dispatch_async(dispatch_get_main_queue(), {
//
//                        let alertMessage = "Tweet 1: \(tweetOne)" + "\n\n" + "Tweet 2: \(tweetTwo)"
//                        let alert = UIAlertController(title: "You tweeted two tweets:", message: alertMessage, preferredStyle: .Alert)
//                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//                            println("OK")
//                        })
//                        alert.addAction(okAction)
//                        
//                        self.presentViewController(alert, animated: true, completion: nil)
//                        
                        completion()
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    completion()
                })
            }
        }
    }
    
    func tweetsFromText(text: String, linksArray: [[String:String]]) -> (tweetOne: String, tweetTwo: String) {
        var tweetOne = text
        var tweetTwo = ""
        
        var addToFirstPart = true
        if count(text) > 140 {
            let components = text.componentsSeparatedByString(" ")
            
            tweetOne = ""
            for word in components {
                if count(tweetOne) + count(word) > 130 {
                    if word.isURL() && count(tweetOne) + 10 < 130 {
                        addToFirstPart = true
                    } else {
                        addToFirstPart = false
                    }
                }
                if addToFirstPart {
                    tweetOne += " \(word)"
                } else {
                    tweetTwo += " \(word)"
                }
            }
        }
        
        if linksArray.count > 0 {
            let linkString = linksArray.first!["url"]!
            if addToFirstPart {
                //                if tweetOne.utf16Count < 130 {
                
                tweetOne += " \(linkString)"
                //                } else {
                //                    dispatch_async(dispatch_get_main_queue(), {
                //
                //                        let alertMessage = "Tweeting was not possible because there would be two tweets but the second one would only have a link in it."
                //                        let alert = UIAlertController(title: "There was an error", message: alertMessage, preferredStyle: .Alert)
                //                        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                //                            println("OK")
                //                        })
                //                        alert.addAction(okAction)
                //
                //                        self.presentViewController(alert, animated: true, completion: nil)
                //
                //                        completion()
                //                    })
                //                    return
                //                }
            } else {
                tweetTwo += " \(linkString)"
            }
        }
        
        if tweetTwo != "" {
            if count(tweetOne) < 134 {
                tweetOne = tweetOne + " ...\n1/2"
            }
            tweetTwo = "... " + tweetTwo + "\n2/2"
            
        }
        
        return (tweetOne, tweetTwo)
    }
}


