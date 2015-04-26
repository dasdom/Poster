//
//  CrossPostPreferenceViewController.swift
//  Poster
//
//  Created by Dominik Hauser on 19/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import Accounts

let kActiveTwitterAccountIdKey = "kActiveTwitterAccountIdKey"
let kCrossPostStateChangedNotification = "kCrossPostStateChangedNotification"

class CrossPostPreferenceViewController: NSViewController {

    @IBOutlet weak var twitterPopUpButton: NSPopUpButton!
    var accountStore: ACAccountStore?
    var accounts: [AnyObject]?
    var activeAccountId: String?
    
    @IBOutlet weak var crosspostToTwitterCheckBox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountStore = ACAccountStore()
        let accountType = accountStore!.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        println("accountType: \(accountType)")

        accountStore!.requestAccessToAccountsWithType(accountType, options: nil, completion: { [unowned self] (granted, error) in
            println("granted: \(granted)")
            self.accounts = self.accountStore?.accounts
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let allAccounts = self.accounts {
                for account in allAccounts as! [ACAccount] {
                    self.twitterPopUpButton.addItemWithTitle(account.username)
                }
                }
            })
            })
        
        let accountIdentifer = NSUserDefaults.standardUserDefaults().stringForKey(kActiveTwitterAccountIdKey)
        if accountIdentifer != nil {
            crosspostToTwitterCheckBox.state = NSOnState
        } else {
            crosspostToTwitterCheckBox.state = NSOffState
        }

    }
    
}

// MARK: - Actions
extension CrossPostPreferenceViewController {
    @IBAction func crossPostCheckBoxChanged(sender: NSButton) {
        
        if sender.state == NSOnState {
            var accountIdentifier: String?
            if let allAccounts = self.accounts {
                for account in allAccounts as! [ACAccount] {
                    if account.username == twitterPopUpButton.selectedItem!.title {
                        NSUserDefaults.standardUserDefaults().setObject(account.identifier, forKey: kActiveTwitterAccountIdKey)
                        break
                    }
                }
            }
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(kActiveTwitterAccountIdKey)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(kCrossPostStateChangedNotification, object: self, userInfo: nil)
    }
    
}
