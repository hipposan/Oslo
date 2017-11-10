//
//  LoginViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 22/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit
import Alamofire
import PromiseKit

class LoginViewController: UIViewController {
  
  @IBOutlet var loginWebView: UIWebView!
  @IBOutlet var loadingIndicator: UIActivityIndicatorView!
  
  @IBAction func backButtonDidPressed(_ sender: Any) {
    dismiss(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
      
      Alamofire.request(Constants.Base.UnsplashURL + Constants.Base.Token, method: HTTPMethod.post, parameters: [
        "client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896",
        "client_secret": "c81b39a6a1f921a0b2b29de29f44fd176ffc101e816c5d2d34b6c951a885a68b",
        "redirect_uri": "Oslo://photos",
        "code": code,
        "grant_type": "authorization_code"
        ]).validate().responseJSON { response in
          guard let json = response.result.value as? [String: Any] else { return }
          
          let accessToken = json["access_token"] as! String
          
          Token.saveToken(accessToken)
          
          self.dismiss(animated: true)
      }
      
      return false
    }
    
    return true
  }
  
  func webViewDidFinishLoad(_ webView: UIWebView) {
    loadingIndicator.stopAnimating()
  }
}
