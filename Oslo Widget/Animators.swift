//
//  Animators.swift
//  Oslo
//
//  Created by Ziyi Zhang on 24/04/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import UIKit

class Animators {
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
  
  static func nextDialog(with view: UIImageView) -> UIViewPropertyAnimator {
    let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut)
    
    animator.addAnimations {
      view.transform = CGAffineTransform(scaleX: 0.9, y: 1.1)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
        view.transform = .identity
      })
    }
    
    return animator
  }
}
