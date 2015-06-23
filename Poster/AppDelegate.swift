//
//  AppDelegate.swift
//  Poster
//
//  Created by dasdom on 12.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import KeychainAccess

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var postController: PosterWindowController?
  var loginController: NSWindowController?
  
    @IBAction func nextAccount(sender: NSMenuItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(SwitchToNextAccountNotification, object: self, userInfo: nil)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
      
      let userDefaults = NSUserDefaults(suiteName: kSuiteName)
      if let username = userDefaults?.stringForKey(kActiveAccountNameKey), accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
        postController = NSStoryboard(name: "Main", bundle: nil)?.instantiateControllerWithIdentifier("PostWindowController") as? PosterWindowController
        postController?.showWindow(self)
      } else {
        loginController = NSStoryboard(name: "Main", bundle: nil)?.instantiateControllerWithIdentifier("LoginWindowController") as? NSWindowController
        loginController?.showWindow(self)
      }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

