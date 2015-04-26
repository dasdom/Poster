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

    @IBOutlet weak var loginButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginOrLogout:", name: DidLoginOrLogoutNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLogin:", name: ShouldLoginWindowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLogout:", name: ShouldLogoutWindowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nextAccount:", name: SwitchToNextAccountNotification, object: nil)
        
//        let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey)
//        println("username: \(username)")
//        let string = "AccessToken_\(username!)"
//        println("string: \(string)")
//        let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)")
//        println("accessToken: \(accessToken)")
        if let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey), let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
            loginButton.title = "Logout"
        } else {
            performSegueWithIdentifier("ShowLogin", sender: self)
        }
    }
    
//    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
//        if identifier == "ShowLogin" {
//            if let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey), let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
//                
//                KeychainAccess.deletePasswortForAccount("AccessToken_\(username)")
//                NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
//                return false
//            }
//        }
//        return true
//    }
}

// MARK: - Notifications actions
extension PosterWindowController {
    func didLoginOrLogout(sender: NSNotification) {
//        let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey)
//        let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)")
        if let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey), let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
            loginButton.title = "Logout"
        } else {
            loginButton.title = "Login"
        }
    }
    
    func showLogin(sender: NSNotification) {
        performSegueWithIdentifier("ShowLogin", sender: self)
    }
    
    func showLogout(sender: NSNotification) {
        if let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey) {
            if let accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)") {
                KeychainAccess.deletePasswortForAccount(accessToken)
            }
            
            if var accountArray = NSUserDefaults.standardUserDefaults().arrayForKey(kAccountNameArrayKey) as? [String], accountIndex = find(accountArray, username) {
                accountArray.removeAtIndex(accountIndex)
                NSUserDefaults.standardUserDefaults().setObject(accountArray, forKey: kAccountNameArrayKey)
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kActiveAccountNameKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
        }
    }
    
    func nextAccount(sender: NSNotification) {
        if let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey) {
            if let accountArray = NSUserDefaults.standardUserDefaults().arrayForKey(kAccountNameArrayKey) as? [String], var accountIndex = find(accountArray, username) {
                ++accountIndex
                if accountIndex >= accountArray.count {
                    accountIndex = 0
                }
                
                let accountName = accountArray[accountIndex]
                NSUserDefaults.standardUserDefaults().setObject(accountName, forKey: kActiveAccountNameKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
                
            }
        }
    }
}
