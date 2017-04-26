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
  
  var portfolioURL: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    portfolioWebView.delegate = self
    
    guard let url = portfolioURL else { return }
    
    let requestURL = URL(string: url)!
    let request = URLRequest(url: requestURL)
    portfolioWebView.loadRequest(request)
  }
}
