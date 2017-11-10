//
//  Framework.swift
//  Oslo
//
//  Created by hippo_san on 05/08/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

public extension UIView {
  public class func load(from xib: String, with frame: CGRect) -> UIView? {
    guard let nibView = Bundle.main.loadNibNamed(xib, owner: self, options: nil) as? [UIView] else { return nil }
    let view = nibView[0]
    view.frame = frame
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    return view
  }
}

public func delay(_ delay: Double, completion: @escaping () -> Void) {
  let time = DispatchTime.now() + delay
  DispatchQueue.main.asyncAfter(deadline: time, execute: completion)
}

extension UIColor {
  public class func colorWithRGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
  }
}

extension Array {
  public func randomItem() -> Element {
    let index = Int(arc4random_uniform(UInt32(self.count)))
    return self[index]
  }
}

extension UIView {
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
}

public func localize(with key: String) -> String {
  return NSLocalizedString(key, comment: "")
}

public func localizedFormat(with key: String, and argument: String) -> String {
  return String(format: localize(with: key), argument)
}

public struct Token {
  public static let userDefaults = UserDefaults(suiteName: "group.com.ziyideas.oslo")!
  
  public static func getToken() -> String? {
    return userDefaults.string(forKey: "token")
  }
  
  public static func saveToken(_ token: String) {
    userDefaults.removeObject(forKey: "token")
    userDefaults.set(token, forKey: "token")
  }
  
  public static func removeToken() {
    userDefaults.removeObject(forKey: "token")
  }
}

