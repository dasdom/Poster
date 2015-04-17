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

class ViewController: NSViewController {
  
  @IBOutlet var textView: NSTextView!
  var accessToken: String?
  var image: NSImage?
  
  @IBOutlet weak var imageView: NSImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if accessToken == nil {
      accessToken = KeychainAccess.passwordForAccount("AccessToken")
    }
  }
  
  override var representedObject: AnyObject? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  @IBAction func post(sender: NSButton) {
    
    println("post")
    
    if accessToken == nil {
      println("no accessToken")
      return
    }
    
    let adnApiCommunicator = ADNAPICommunicator()
    adnApiCommunicator.postText(textView.string!, linksArray: [], accessToken: accessToken!, image: image) { () -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.textView.string = ""
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

