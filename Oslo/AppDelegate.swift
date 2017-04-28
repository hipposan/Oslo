//
//  AppDelegate.swift
//  Oslo
//
//  Created by hippo_san on 6/1/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.host == "Login" {
      guard let navController = window?.rootViewController as? UINavigationController,
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return false }
      
      navController.present(loginViewController, animated: false)
      
      return true
    }
    
    return false
  }

}

