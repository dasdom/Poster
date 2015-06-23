//
//  PostCellView.swift
//  ADNExperiments
//
//  Created by dasdom on 25.05.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa

class PostCellView: NSTableCellView {
  
  @IBOutlet weak var avatarImageView: NSImageView!
  @IBOutlet weak var usernameLabel: NSTextField!
  @IBOutlet weak var postLabel: NSTextField!
  
  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)
    
    // Drawing code here.
  }
  
}
