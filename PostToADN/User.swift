//
//  User.swift
//  Poster
//
//  Created by Dominik Hauser on 24/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation

public struct User {
    public let username: String
    public let userId: Int
    
    public init(dataDictionary: [String:AnyObject]) {
        username = dataDictionary["username"] as! String
        userId = (dataDictionary["id"] as! String).toInt()!
    }
}