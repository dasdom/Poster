//
//  User.swift
//  ADNExperiments
//
//  Created by dasdom on 24.05.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation

public struct User : Printable {
  public let userId: Int
  public let username: String
  public let name: String
  public let avatarURLString: String
  public let followers: Int
  public let following: Int
  
  public var description: String {
    return "@\(username), \(name), \(followers), \(following)"
  }
  
//  public init(dataDictionary: [String:AnyObject]) {
//    userId = (dataDictionary["id"] as! String).toInt()!
//    username = dataDictionary["username"] as! String
//    name = dataDictionary["name"] as! String
//    let avatar = dataDictionary["avatar_image"] as! [String:AnyObject]
//    avatarURLString = avatar["url"] as! String
//    let counts = dataDictionary["counts"] as! [String:Int]
//    followers = counts["followers"]!
//    following = counts["following"]!
//  }
  
//  init(username: String, name: String, avatarURLString: String, followers: Int, following: Int) {
//    self.username = username
//    self.name = name
//    self.avatarURLString = avatarURLString
//    self.followers = followers
//    self.following = following
//  }
}