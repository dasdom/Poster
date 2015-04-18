//
//  ViewController.swift
//  Poster
//
//  Created by dasdom on 12.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import PostToADN
import KeychainAccess
import Quartz

let DidLoginOrLogoutNotification = "DidLoginOrLogoutNotification"

class ViewController: NSViewController, NSTextViewDelegate {
  
  @IBOutlet var textView: NSTextView!
  var accessToken: String?
  var image: NSImage?
  
  @IBOutlet weak var imageView: NSImageView!
  @IBOutlet weak var characterCountLabel: NSTextField!
  
    @IBOutlet weak var avatarImageView: NSImageView!
    
  override var representedObject: AnyObject? {
    didSet {
      // Update the view, if already loaded.
    }
  }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginOrLogout:", name: DidLoginOrLogoutNotification, object: nil)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateView()
    }
    
    func updateView() {
        if accessToken == nil {
            accessToken = KeychainAccess.passwordForAccount("AccessToken")
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
  
  func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String) -> Bool {
    let numberOfCharacters = count(textView.string!) - affectedCharRange.length + count(replacementString)
    characterCountLabel.stringValue = "\(256-numberOfCharacters)"
    return true
  }
  
  @IBAction func post(sender: NSButton) {
    
    println("post")
    
    if accessToken == nil {
      accessToken = KeychainAccess.passwordForAccount("AccessToken")
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
    
    let adnApiCommunicator = ADNAPICommunicator()
    adnApiCommunicator.postText(textView.string!, linksArray: [], accessToken: accessToken!, image: image) { () -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.textView.string = ""
        self.image = nil
        self.imageView.image = nil
      });
    }
    
  }
  
  @IBAction func changePicture(sender: AnyObject) {
      IKPictureTaker().beginPictureTakerSheetForWindow(self.view.window,
        withDelegate: self,
        didEndSelector: "pictureTakerDidEnd:returnCode:contextInfo:",
        contextInfo: nil)
  }
  
  func pictureTakerDidEnd(picker: IKPictureTaker, returnCode: NSInteger, contextInfo: UnsafePointer<Void>) {
    let image = picker.outputImage()
    
    if image != nil && returnCode == NSModalResponseOK {
      self.imageView.image = image
      self.image = image
    }
  }
  
}

extension ViewController {
    func didLoginOrLogout(sender: NSNotification) {
        accessToken = nil
        updateView()
    }
}

