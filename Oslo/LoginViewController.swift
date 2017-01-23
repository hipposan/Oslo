//
//  LoginViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 22/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  @IBOutlet var loginWebView: UIWebView!
  @IBOutlet var backButton: UIButton!
  
  @IBAction func backButtonDidPressed(_ sender: Any) {
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backButton.setTitle(localize(with: "Back"), for: .normal)
    
    loginWebView.delegate = self
    
    let authorizationURL = NetworkService.parse(URL(string: Constants.Base.UnsplashURL + Constants.Base.Authorize)!, with: [
        Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
        Constants.Parameters.ResponseType as Dictionary<String, AnyObject>,
        Constants.Parameters.RedirectURI as Dictionary<String, AnyObject>,
        Constants.Parameters.Scope as Dictionary<String, AnyObject>
      ])
    
    let request = URLRequest(url: authorizationURL)
    loginWebView.loadRequest(request)
  }
}

extension LoginViewController: UIWebViewDelegate {
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    let absoluteURL = request.url!.absoluteString
    
    if absoluteURL.contains("oslo://photos") {
      let code = absoluteURL.components(separatedBy: "=")[1]
      
      NetworkService.request(url: URL(string: Constants.Base.UnsplashURL + Constants.Base.Token)!, method: NetworkService.HTTPMethod.POST, parameters: [
        Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
        Constants.Parameters.ClientSecret as Dictionary<String, AnyObject>,
        Constants.Parameters.RedirectURI as Dictionary<String, AnyObject>,
        ["code": code as AnyObject],
        Constants.Parameters.GrantType as Dictionary<String, AnyObject>
      ]) { jsonData in
        let accessToken = jsonData["access_token"] as! String
        
        Token.saveToken(accessToken)
        
        self.dismiss(animated: true)
      }
      
      return false
    }
    
    return true
  }
}
