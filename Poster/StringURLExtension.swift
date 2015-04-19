//
//  StringURLExtension.swift
//  Poster
//
//  Created by Dominik Hauser on 19/04/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation

extension String {
    
    func isURL() -> Bool {
        let url = NSURL(string: self)
        return url != nil
    }
    
}