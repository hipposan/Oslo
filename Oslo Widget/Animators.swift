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
  
}
