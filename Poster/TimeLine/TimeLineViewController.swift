//
//  TimeLineViewController.swift
//  Poster
//
//  Created by dasdom on 25.05.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import ADN
import KeychainAccess

class TimeLineViewController: NSViewController {

  var accessToken: String?
  var posts: [Post] = []
  @IBOutlet weak var tableView: NSTableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    if accessToken == nil {
      let userDefaults = NSUserDefaults(suiteName: kSuiteName)
      if let username = userDefaults?.stringForKey(kActiveAccountNameKey) {
        accessToken = KeychainAccess.passwordForAccount("AccessToken_\(username)")
      }
    }

    let adnApiCommunicator = ADNAPICommunicator()
    adnApiCommunicator.personalizedStreamWithAccessToken(accessToken!, completion: { (posts, error) -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if let posts = posts {
          println(posts)
          self.posts = posts
        }
        self.tableView.reloadData()
      })
    })
  }
  
}

extension TimeLineViewController : NSTableViewDataSource {
  func numberOfRowsInTableView(tableView: NSTableView) -> Int {
    return posts.count
  }
}

extension TimeLineViewController : NSTableViewDelegate {
  
  func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    let post = posts[row]
    
    let cellView = tableView .makeViewWithIdentifier("PostCell", owner: self) as! PostCellView
    cellView.usernameLabel.stringValue = post.user.username
    cellView.postLabel.attributedStringValue = post.text
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
      let image = NSImage(contentsOfURL: NSURL(string: post.user.avatarURLString)!)
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        cellView.avatarImageView.image = image
      })
    })
    
    
    return cellView
  }
}
