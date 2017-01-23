//
//  PortfolioWebViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 06/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class PortfolioWebViewController: UIViewController, UIWebViewDelegate {
  
  @IBOutlet var portfolioWebView: UIWebView!
  
  var portfolioURL = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    portfolioWebView.delegate = self
    
    let requestURL = URL(string: portfolioURL)!
    let request = URLRequest(url: requestURL)
    portfolioWebView.loadRequest(request)
  }
}
