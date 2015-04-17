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
    
}
