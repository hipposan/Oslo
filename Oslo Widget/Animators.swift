//
//  Animators.swift
//  Oslo
//
//  Created by Ziyi Zhang on 24/04/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit

class Animators {
  static func showWidget(with widgetView: UIView) -> UIViewPropertyAnimator {
    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut)
    
    animator.addAnimations {
      widgetView.alpha = 1
    }
    animator.addAnimations({
      widgetView.layer.transform = CATransform3DIdentity
    }, delayFactor: 0.3)
    
    return animator
  }
  
  static func showProfileImage(with profileImageView: UIImageView) -> UIViewPropertyAnimator {
    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut)
    
    animator.addAnimations {
      profileImageView.alpha = 1
      profileImageView.transform = .identity
    }
    
    return animator
  }
  
  static func hideProfileImage(with profileImageView: UIImageView) -> UIViewPropertyAnimator {
    let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut)
    
    animator.addAnimations {
      profileImageView.alpha = 0
      profileImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 3)).scaledBy(x: 0.6, y: 0.6).translatedBy(x: -90, y: 0)
    }
    
    return animator
  }
}
