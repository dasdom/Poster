//
//  ADNAccountsPreferenceViewController.swift
//  Poster
//
//  Created by Dominik Hauser on 24/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa

let ShouldLoginWindowNotification = "ShouldLoginWindowNotification"
let ShouldLogoutWindowNotification = "ShouldLogoutWindowNotification"

class ADNAccountsPreferenceViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    var accounts = [String]()
    var rowOfSelectedAccount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAddOrRemoveAccount:", name: DidAddOrRemoveAccountNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadAccountsIfNeeded:", name: DidLoginOrLogoutNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func loadAccounts() {
        if let accounts = NSUserDefaults.standardUserDefaults().arrayForKey(kAccountNameArrayKey) as? [String] {
            self.accounts = accounts
            
            tableView.reloadData()

            if let username = NSUserDefaults.standardUserDefaults().stringForKey(kActiveAccountNameKey) {
                rowOfSelectedAccount = find(accounts, username)
            }
         
            if let row = rowOfSelectedAccount {
                tableView.selectRowIndexes(NSIndexSet(index: row), byExtendingSelection: false)
            }
            
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.loadAccounts()
    }
}

extension ADNAccountsPreferenceViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return accounts.count
    }
}

extension ADNAccountsPreferenceViewController: NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // 1
        var cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        // 2
        if tableColumn!.identifier == "AccountsColumn" {
            // 3
            let accountName = self.accounts[row]
            cellView.textField!.stringValue = accountName
            return cellView
        }
        
        return cellView
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let username = self.accounts[tableView.selectedRow]

        NSUserDefaults.standardUserDefaults().setObject(username, forKey: kActiveAccountNameKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
    }
    
}

// MARK: - Actions
extension ADNAccountsPreferenceViewController {
    
    @IBAction func addAccount(sender: NSButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(ShouldLoginWindowNotification, object: self, userInfo: nil)
    }
    
    @IBAction func removeAccount(sender: NSButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(ShouldLogoutWindowNotification, object: self, userInfo: nil)
    }
}

// MARK: Notification actions
extension ADNAccountsPreferenceViewController {
    func loadAccountsIfNeeded(sender: NSNotification) {
        if !(sender.object is ADNAccountsPreferenceViewController) {
            loadAccounts()
        }
    }
}