//
//  NSImageExtensions.swift
//  Poster
//
//  Created by dasdom on 17.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation

public extension NSImage {
  public func jpegDataWithCompressionFactor(compressionFactor: Double) -> NSData? {
    if var imageData = TIFFRepresentation {
      let imageRep = NSBitmapImageRep(data: imageData)
      let imageProperties = [NSImageCompressionFactor: compressionFactor]
        return imageRep?.representationUsingType(NSBitmapImageFileType.NSJPEGFileType, properties: imageProperties)
    }
    return nil
  }
}