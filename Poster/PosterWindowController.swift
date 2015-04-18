//
//  PosterWindowController.swift
//  Poster
//
//  Created by Dominik Hauser on 18/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import KeychainAccess

class PosterWindowController: NSWindowController {

    @IBOutlet weak var loginButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginOrLogout:", name: DidLoginOrLogoutNotification, object: nil)
        
        let accessToken = KeychainAccess.passwordForAccount("AccessToken")
        if accessToken == nil {
            performSegueWithIdentifier("ShowLogin", sender: self)
        } else {
            loginButton.title = "Logout"
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "ShowLogin" {
            if let accessToken = KeychainAccess.passwordForAccount("AccessToken") {
                KeychainAccess.deletePasswortForAccount("AccessToken")
                NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
                return false
            }
        }
        return true
    }
}

extension PosterWindowController {
    func didLoginOrLogout(sender: NSNotification) {
        let accessToken = KeychainAccess.passwordForAccount("AccessToken")
        if accessToken != nil {
            loginButton.title = "Logout"
        } else {
            loginButton.title = "Login"
        }
    }
}
