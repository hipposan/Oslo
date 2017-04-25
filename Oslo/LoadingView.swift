//
//  LoadingView.swift
//  Oslo
//
//  Created by Ziyi Zhang on 07/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit

class LoadingView: UIView {
  private let images = [#imageLiteral(resourceName: "mountain"), #imageLiteral(resourceName: "kaminarimon_gate"), #imageLiteral(resourceName: "tram"), #imageLiteral(resourceName: "blitzcam")]
  private var imageView: UIImageView! {
    didSet {
      imageView.contentMode = .scaleAspectFit
      imageView.frame = CGRect(x: self.frame.size.width / 2 - 20, y: self.frame.size.height / 2 - 20, width: 40, height: 40)
    }
  }
  private var count: Int = 0
  private let transitions: [UIViewAnimationOptions] = [.transitionFlipFromLeft, .transitionFlipFromRight, .transitionFlipFromTop, .transitionFlipFromBottom]
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.white
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func loopImage() {
    if count < images.count {
      UIView.transition(with: self.imageView, duration: 0.5, options: [transitions.randomItem(), .curveEaseInOut], animations: {
        self.imageView.image = self.images[self.count]
      }, completion: { _ in
        delay(0.5) {
          self.count += 1
          self.loopImage()
        }
      })
    } else {
      count = 0
      loopImage()
    }
  }
  
  override func draw(_ rect: CGRect) {
    imageView = UIImageView()
    
    self.addSubview(imageView)
    
    loopImage()
  }
}
