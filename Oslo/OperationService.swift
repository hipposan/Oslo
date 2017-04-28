//
//  Operation.swift
//  Oslo
//
//  Created by Ziyi Zhang on 18/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import Foundation

public struct Token {
  public static let userDefaults = UserDefaults(suiteName: "group.com.ziyideas.oslo")!
  
  public static func getToken() -> String? {
    return userDefaults.string(forKey: "token")
  }
  
  public static func saveToken(_ token: String) {
    userDefaults.set(token, forKey: "token")
  }
  
  public static func removeToken() {
    userDefaults.removeObject(forKey: "token")
  }
}
