//
//  Post.swift
//  ADNExperiments
//
//  Created by dasdom on 24.05.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation

public struct Post : Printable {
  public let id: Int
  public let threadId: Int
  public let text: NSAttributedString
  public let date: NSDate
  public let numReplies: Int
  public let numReposts: Int
  public let numStars: Int
  public let user: User
  public let links: [Link]?
  public let mentions: [Mention]?
  public let hashtags: [Hashtag]?
  
  public var description: String {
    return "@\(user.username)\n\(text), \n\(id), \(threadId), \(date), \(numReplies), \(numReposts), \(numStars), \(user)"
  }
  
//  public init(dataDictionary: [String:AnyObject]) {
//    text = dataDictionary["text"] as! String
//    id = (dataDictionary["id"] as! String).toInt()!
//    threadId = (dataDictionary["thread_id"] as! String).toInt()!
//    dateString = dataDictionary["created_at"] as! String
//    numReplies = dataDictionary["num_replies"] as! Int
//    numReposts = dataDictionary["num_reposts"] as! Int
//    numStars = dataDictionary["num_stars"] as! Int
//  }
  
//  init(id: Int, threadId: Int, text: String, date: NSDate, numReplies: Int, numReposts: Int, numStars: Int, user: User) {
//    self.id = id
//    self.threadId = threadId
//    self.text = text
//    self.date = date
//    self.numReplies = numReplies
//    self.numReposts = numReposts
//    self.numStars = numStars
//    self.user = user
//  }
}

public struct Link {
  public let pos: Int
  public let len: Int
  public let text: String
  public let urlString: String
  
//  public init(dataDictionary: [String:AnyObject]) {
//    pos = dataDictionary["pos"] as! Int
//    len = dataDictionary["len"] as! Int
//    text = dataDictionary["text"] as! String
//    urlString = dataDictionary["url"] as! String
//  }
}

public struct Mention {
  public let pos: Int
  public let len: Int
  public let id: Int
  public let name: String
  public let isLeading: Bool?
  
//  public init(dataDictionary: [String:AnyObject]) {
//    pos = dataDictionary["pos"] as! Int
//    len = dataDictionary["len"] as! Int
//    id = (dataDictionary["id"] as! String).toInt()!
//    name = dataDictionary["name"] as! String
//    isLeading = dataDictionary["is_leading"] as? Bool
//  }
}

public struct Hashtag {
  public let pos: Int
  public let len: Int
  public let name: String
  
//  public init(dataDictionary: [String:AnyObject]) {
//    pos = dataDictionary["pos"] as! Int
//    len = dataDictionary["len"] as! Int
//    name = dataDictionary["name"] as! String
//  }
}

