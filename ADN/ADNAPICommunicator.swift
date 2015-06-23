//
//  ADNAPICommunicator.swift
//  Jupp
//
//  Created by dasdom on 03.12.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Cocoa

public class ADNAPICommunicator: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate {
  
  var data = NSMutableData()
  var postText = String()
  var accessToken = String()
  var session = NSURLSession()
  
  public func uploadImage(image: NSImage, accessToken: String, completion: ([String: AnyObject]) -> () ) {
    
    let imageUploadRequest = RequestFactory.imageUploadRequest(image, accessToken: accessToken)
    
    session = NSURLSession.sharedSession()
    let sessionTask = session.dataTaskWithRequest(imageUploadRequest, completionHandler: { (data, response, error) -> Void in
      
      let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
      println("uploadImage dataString \(dataString)")
      
      let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! [String: AnyObject]
      completion(dictionary)
    })
    sessionTask.resume()
  }
  
  public func postText(text: String, linksArray: [[String:String]], accessToken: String, image: NSImage?, completion: () -> ()) {
    
    func postText(text: String, linksArray: [[String:String]], accessToken: String, imageDict: [String:AnyObject]?, completion: () -> ()) {
      let request = RequestFactory.postRequestFromPostText(text, linksArray: linksArray, accessToken: accessToken, imageDict: imageDict)
      
      let session = NSURLSession.sharedSession()
      let sessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
        
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("postText dataString \(dataString)")
        completion()
      })
      sessionTask.resume()
    }
    
    if let image = image {
      uploadImage(image, accessToken: accessToken) { (dictionary) -> () in
        let imageDict = dictionary["data"] as? [String:AnyObject]
        
        postText(text, linksArray, accessToken, imageDict, { () -> () in
          completion()
        })
      }
    } else {
      postText(text, linksArray, accessToken, nil, { () -> () in
        completion()
      })
    }
    
  }
  
  public func avatarWithAccessToken(accessToken: String, completion: (NSImage?) -> ()) {
    let request = RequestFactory.avatarRequestWithAccessToken(accessToken)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      let image = NSImage(data: data)
      completion(image)
    })
    task.resume()
  }
  
  public func loggedInUserWithAccessToken(accessToken: String, completion: (User) -> ()) {
    let request = RequestFactory.loggedInUserInfoRequestWithAccessToken(accessToken)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var jsonError: NSError?
      let rawResponseDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as! [String:AnyObject]
      //            println("dataDict: \(rawResponseDictionary)")
      
      let dataDictionary = rawResponseDictionary["data"] as! [String:AnyObject]
      
      let userId = (dataDictionary["id"] as! String).toInt()!
      let username = dataDictionary["username"] as! String
      let name = dataDictionary["name"] as! String
      let avatar = dataDictionary["avatar_image"] as! [String:AnyObject]
      let avatarURLString = avatar["url"] as! String
      let counts = dataDictionary["counts"] as! [String:Int]
      let followers = counts["followers"]!
      let following = counts["following"]!
      
      let user = User(userId: userId, username: username, name: name, avatarURLString: avatarURLString, followers: followers, following: following)
      
      completion(user)
    })
    task.resume()
  }
  
  public func personalizedStreamWithAccessToken(accessToken: String, completion: ([Post]?, NSError?) -> ()) {
    let request = RequestFactory.personalizedStreamRequestWithAccessToken(accessToken)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      var jsonError: NSError?
      let rawResponseDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as! [String:AnyObject]
                  println("dataDict: \(rawResponseDictionary)")
      
      let data = rawResponseDictionary["data"] as! [AnyObject]
      
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy_MM_dd'T'HH_mm_ss'Z'"
      
      var postsToAdd = [Post]()
      for post in data {
        //                    println("post: \(post)")
        if let text = post["text"] as? String,
          id = (post["id"] as? String)?.toInt(),
          threadId = (post["thread_id"] as? String)?.toInt(),
          dateString = post["created_at"] as? String,
          numReplies = post["num_replies"] as? Int,
          numReposts = post["num_reposts"] as? Int,
          numStars = post["num_stars"] as? Int,
          rawUser = post["user"] as? [String:AnyObject] {
            
            if let userId = (rawUser["id"] as? String)?.toInt(),
              username = rawUser["username"] as? String,
              name = rawUser["name"] as? String,
              avatar = rawUser["avatar_image"] as? [String:AnyObject],
              avatarURLString = avatar["url"] as? String,
              counts = rawUser["counts"] as? [String:Int],
              followers = counts["followers"],
              following = counts["following"] {
                
                let user = User(userId: userId, username: username, name: name, avatarURLString: avatarURLString, followers: followers, following: following)
                if let date = dateFormatter.dateFromString(dateString) {
                  
                  let attributedString = NSMutableAttributedString(string: text)
                  
                  let entities = post["entities"] as? [String:AnyObject]
                  
                  var links = [Link]()
                  if let rawLinks = entities?["links"] as? [[String:AnyObject]] {
                    for rawLink in rawLinks {
                      if let pos = rawLink["pos"] as? Int,
                        len = rawLink["len"] as? Int,
                        text = rawLink["text"] as? String,
                        urlString = rawLink["url"] as? String {
                          let link = Link(pos: pos, len: len, text: text, urlString: urlString)
                          links.append(link)
                          attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange(location: pos, length: len))
                      }
                    }
                  }
                  
                  var mentions = [Mention]()
                  if let rawMentions = entities?["mentions"] as? [[String:AnyObject]] {
                    for rawMention in rawMentions {
                      println("rawMention: \(rawMention)")
                      if let pos = rawMention["pos"] as? Int,
                        len = rawMention["len"] as? Int,
                        id = (rawMention["id"] as? String)?.toInt(),
                        name = rawMention["name"] as? String {
                          println("within if")
                          let isLeading = rawMention["is_leading"] as? Bool
                          let mention = Mention(pos: pos, len: len, id: id, name: name, isLeading: isLeading)
                          mentions.append(mention)
                          attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: NSRange(location: pos, length: len))
                      }
                    }
                  }
                  
                  var hashtags = [Hashtag]()
                  if let rawHashtags = entities?["hashtags"] as? [[String:AnyObject]] {
                    for rawHashtag in rawHashtags {
                      println("rawMention: \(rawHashtag)")
                      if let pos = rawHashtag["pos"] as? Int,
                        len = rawHashtag["len"] as? Int,
                        name = rawHashtag["name"] as? String {
                          println("within if")
                          let hashtag = Hashtag(pos: pos, len: len, name: name)
                          hashtags.append(hashtag)
                          attributedString.addAttribute(NSForegroundColorAttributeName, value: NSColor.blueColor(), range: NSRange(location: pos, length: len))
                      }
                    }
                  }
                  
                  let post = Post(id: id, threadId: threadId, text: attributedString, date: date, numReplies: numReplies, numReposts: numReposts, numStars: numStars, user: user, links: links, mentions: mentions, hashtags: hashtags)
                  //            println("\(dateString)")
                  //                    println("*** \(post) **********")
                  //            println("\(text)\n\n")
                  postsToAdd.append(post)
                }
            }
        }
      }
      completion(postsToAdd, nil)
    })
    task.resume()
  }
  
}
