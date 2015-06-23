//
//  ImageService.swift
//  Jupp
//
//  Created by dasdom on 05.12.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Cocoa

public class ImageService: NSObject {
  
  public func saveImageToUpload(image: NSImage, name: String) -> NSURL? {
    return saveImage(image, name: name, imageUrl: imagesToUploadDirectoryURL())
  }
  
  public func saveImage(image: NSImage, name: String, imageUrl: NSURL) -> NSURL? {
    var imageDirectoryURL = imageUrl
    imageDirectoryURL = imageDirectoryURL.URLByAppendingPathComponent(name)
    imageDirectoryURL = imageDirectoryURL.URLByAppendingPathExtension("jpg")
    if let imageData = image.jpegDataWithCompressionFactor(0.5) {
      let saved = imageData.writeToFile(imageDirectoryURL.path!, atomically: true)
      return imageDirectoryURL
    }
    return nil
  }
  
  private func imagesToUploadDirectoryURL() -> NSURL {
    return urlForDirectoryWithName("Uploads")
  }
  
  private func urlForDirectoryWithName(name: String) -> NSURL! {
    if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.de.dasdom.Jupp") {
      var contairURLWithName = containerURL.URLByAppendingPathComponent(name)
      if !NSFileManager.defaultManager().fileExistsAtPath(contairURLWithName.path!) {
        NSFileManager.defaultManager().createDirectoryAtPath(containerURL.path!, withIntermediateDirectories: false, attributes: nil, error: nil)
      }
      
      return containerURL    } else {
      fatalError("Unable to obtain container URL for app group, verify your app group settings.")
      return nil
    }
  }
}
