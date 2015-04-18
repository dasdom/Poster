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

class WebLoginViewController: NSViewController, WKNavigationDelegate {
  
//  @IBOutlet weak var webView: WebView!
  
  var webView: WKWebView!
  
  var progressIndicator: NSProgressIndicator!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let request = NSURLRequest(URL: NSURL(string: "https://account.app.net/oauth/authorize?client_id=rj4NmMD2y6Utf5aqnjuHVS3hchgAFsta&response_type=token&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=write_post")!)
    
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
        KeychainAccess.setPassword(title, account: "AccessToken")
        NSNotificationCenter.defaultCenter().postNotificationName(DidLoginOrLogoutNotification, object: self, userInfo: nil)
        dismissViewController(self)
      }
    }
  }

  
}
