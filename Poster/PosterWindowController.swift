//
//  PosterWindowController.swift
//  Poster
//
//  Created by Dominik Hauser on 18/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import KeychainAccess

let SwitchToNextAccountNotification = "SwitchToNextAccountNotification"

class PosterWindowController: NSWindowController {
  
  var loginController: NSWindowController?
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginOrLogout:", name: DidLoginOrLogoutNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLogin:", name: ShouldLoginWindowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLogout:", name: ShouldLogoutWindowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "nextAccount", name: SwitchToNextAccountNotification, object: nil)
    
    let userDefaults = NSUserDefaults(suiteName: kSuiteName)
    if let username = userDefaults?.stringForKey(kActiveAccountNameKey), accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
      
    } else {
      ////            performSegueWithIdentifier("ShowLogin", sender: self)
      //          loginController = storyboard?.instantiateControllerWithIdentifier("LoginWindowController") as? NSWindowController
      //          loginController?.showWindow(self)
      //          if let window = loginController?.window {
      ////            NSApplication.sharedApplication().runModalForWindow(window)
      ////            window.makeKeyAndOrderFront(self)
      //            self.window?.beginSheet(window, completionHandler: { (response) -> Void in
      //
      //            })
      //          }
    }
  }
  
}

// MARK: - Notifications actions
extension PosterWindowController {
  //    func didLoginOrLogout(sender: NSNotification) {
  //
  //        let userDefaults = NSUserDefaults(suiteName: kSuiteName)
  //        if let username = userDefaults?.stringForKey(kActiveAccountNameKey), let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
  //            loginButton.title = "Logout"
  //        } else {
  //            loginButton.title = "Login"
  //        }
  //    }
  
  func showLogin(sender: NSNotification) {
    performSegueWithIdentifier("ShowLogin", sender: self)
  }
  
  func showLogout(sender: NSNotification) {
    let userDefaults = NSUserDefaults(suiteName: kSuiteName)
    if let username = userDefaults?.stringForKey(kActiveAccountNameKey) {
      if let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
        KeychainAccess.deletePasswortForAccount(accessToken)
        nextAccount()
      }
      
      if var accountArray = userDefaults?.arrayForKey(kAccountNameArrayKey) as? [String], accountIndex = find(accountArray, username) {
        accountArray.removeAtIndex(accountIndex)
        userDefaults?.setObject(accountArray, forKey: kAccountNameArrayKey)
        userDefaults?.synchronize()
        
        userDefaults?.removeObjectForKey(kActiveAccountNameKey)
        userDefaults?.synchronize()
      }
      
      NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
    }
  }
  
  func nextAccount() {
    let userDefaults = NSUserDefaults(suiteName: kSuiteName)
    if let username = userDefaults?.stringForKey(kActiveAccountNameKey) {
      if let accountArray = userDefaults?.arrayForKey(kAccountNameArrayKey) as? [String], var accountIndex = find(accountArray, username) {
        ++accountIndex
        if accountIndex >= accountArray.count {
          accountIndex = 0
        }
        
        let accountName = accountArray[accountIndex]
        
        userDefaults?.setObject(accountName, forKey: kActiveAccountNameKey)
        userDefaults?.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
        
      }
    }
  }
}
