//
//  WebLoginViewController.swift
//  Poster
//
//  Created by dasdom on 12.04.15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Cocoa
import WebKit
import KeychainAccess
import ADN

let kAccountNameArrayKey = "kAccountNameArrayKey"
let kActiveAccountNameKey = "kActiveAccountNameKey"

class WebLoginViewController: NSViewController, WKNavigationDelegate {
  
  //  @IBOutlet weak var webView: WebView!
  
  var webView: WKWebView!
  
  var progressIndicator: NSProgressIndicator!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var urlString = "https://account.app.net/oauth/authenticate?client_id=\(kClientId)&response_type=token&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=write_post stream"
    let request = NSMutableURLRequest(URL: NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)
    
    //    request.HTTPShouldHandleCookies = false
    
    //    let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    //    if let allCookies = storage.cookies {
    //        for cookie in allCookies as! [NSHTTPCookie] {
    //            println("cookie domain: \(cookie.domain)")
    //            if cookie.domain == "account.app.net" {
    //                storage.deleteCookie(cookie)
    //            }
    //        }
    //    }
    
    webView = WKWebView(frame: NSRect.zeroRect)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.navigationDelegate = self
    view.addSubview(webView)
    
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[webView(450)]|", options: nil, metrics: nil, views: ["webView": webView]))
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView(450)]|", options: nil, metrics: nil, views: ["webView": webView]))
    
    progressIndicator = NSProgressIndicator()
    progressIndicator.displayedWhenStopped = false
    progressIndicator.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(progressIndicator)
    
    NSLayoutConstraint(item: progressIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0).active = true
    NSLayoutConstraint(item: progressIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0).active = true
    
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[progressIndicator(50)]", options: nil, metrics: nil, views: ["progressIndicator": progressIndicator]))
    NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[progressIndicator(50)]", options: nil, metrics: nil, views: ["progressIndicator": progressIndicator]))
    
    
    webView.loadRequest(request)
    progressIndicator.startAnimation(self)
    
    println("viewDidLoad")
  }
  
  func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
    progressIndicator.startAnimation(self)
  }
  
  func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
    
    progressIndicator.stopAnimation(self)
    
    if let title = webView.title {
      let length = title.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
      if length > 30 {
        let accessToken = title
        
        webView.loadHTMLString("Fetching username", baseURL: nil)
        
        let apiCommunicator = ADNAPICommunicator()
        apiCommunicator.loggedInUserWithAccessToken(accessToken) { user in
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let user = user
            println("username: \(user.username)")
            
            let accountKey = "AccessToken_\(user.username)"
            KeychainAccess.setPassword(accessToken, account: accountKey)
            
            let userDefaults = NSUserDefaults(suiteName: kSuiteName)
            var array = userDefaults?.arrayForKey(kAccountNameArrayKey)
            if array == nil {
              array = [String]()
            }
            
            array!.append(user.username)
            userDefaults?.setObject(array!, forKey: kAccountNameArrayKey)
            
            userDefaults?.setObject(user.username, forKey: kActiveAccountNameKey)
            userDefaults?.synchronize()
            //              println("userdefaults \(userDefaults?.dictionaryRepresentation())")
            
            NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
            //                NSApplication.sharedApplication().stopModal()
            if let window = NSApplication.sharedApplication().keyWindow {
              print(window)
              window.close()
            }
          });
        }
      }
    }
  }
  
}
