//
//  BackgroundView.swift
//  Poster
//
//  Created by dasdom on 14.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa

class BackgroundView: NSView {
  
  override func drawRect(dirtyRect: NSRect) {
    super.drawRect(dirtyRect)
    
    NSColor.whiteColor().set()
    NSRectFill(dirtyRect)
  }
  
}
