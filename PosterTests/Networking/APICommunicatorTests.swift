//
//  APICommunicatorTests.swift
//  Poster
//
//  Created by dasdom on 12.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import XCTest
import Poster

class APICommunicatorTests: XCTestCase {
  
//  var apiCommunicator: APICommunicator?
  
  override func setUp() {
    super.setUp()
    
//    apiCommunicator = APICommunicator()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
//  func testLoginCallCanBeDone() {
//    // given
//    let mockURLSession = MockURLSession()
//    apiCommunicator.urlSession = mockURLSession
//    
//    // when
//    apiCommunicator.loginWithUsername(username: String, password: String)
//    
//    // then
//    XCTAssertEqual("", <#expression2: T#>, <#message: String#>)
//    XCTAssertEqual(1, mockURLSession.callCount)
//  }
  
//  func testPostCallCanBeDone() {
//    // given
//    let mockURLSession = MockURLSession()
//    apiCommunicator.urlSession = mockURLSession
//    
//    // when
//    apiCommunicator.postText("Test post")
//    
//    // then
//    XCTAssertEqual("", mockURLSession.request!.URL!.absoluteString)
//  }
  
  class MockURLSession: NSURLSession {
    
    var callCount = 0
    var task = MockURLSessionDataTask()
    
    var request: NSURLRequest?
    
    typealias CompletionHandler = (NSData!, NSURLResponse!, NSError!) -> Void
    var completionHandler: CompletionHandler?
    
    override func dataTaskWithRequest(request: NSURLRequest, completionHandler: ((NSData!, NSURLResponse!, NSError!) -> Void)?) -> NSURLSessionDataTask {
      self.request = request
      self.completionHandler = completionHandler
      ++callCount
      return task
    }
    
    class MockURLSessionDataTask: NSURLSessionDataTask {
      
      var resumeCallCount = 0
      
      override func resume() {
        ++resumeCallCount
      }
    }
  }
  
}
