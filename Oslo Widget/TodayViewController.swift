//
//  TodayViewController.swift
//  Oslo Widget
//
//  Created by hippo_san on 23/04/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import UIKit
import NotificationCenter

import OsloKit

class TodayViewController: UIViewController {
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet var luckBackgroundView: UIVisualEffectView!
  @IBOutlet weak var diceImageView: UIImageView!
  @IBOutlet var likeBackgroundView: UIVisualEffectView!
  @IBOutlet weak var brokenHeartImageView: UIImageView!
  @IBOutlet weak var viewCountLabel: UILabel!
  @IBOutlet weak var downloadCountLabel: UILabel!
  @IBOutlet weak var infoStackView: UIStackView!
  @IBOutlet weak var profileImageView: UIImageView!
  
  private let diceImages = [#imageLiteral(resourceName: "Dice1"), #imageLiteral(resourceName: "Dice2"), #imageLiteral(resourceName: "Dice3"), #imageLiteral(resourceName: "Dice4"), #imageLiteral(resourceName: "Dice5"), #imageLiteral(resourceName: "Dice6")]
  private var showProfileImageAnimator: UIViewPropertyAnimator!
  private var isShuffleStopped = true
  
  @IBAction func likeItButton(_ sender: Any) {
    isShuffleStopped = true
  }
  
  @IBAction func nextLuckButton(_ sender: Any) {
    if !isShuffleStopped {
      return
    } else {
      isShuffleStopped = false
      
      shuffle()
    }
  }
  
  @IBAction func showProfileImageButtonDidPressed(_ sender: Any) {
    if profileImageView.alpha == 0 {
      Animators.showProfileImage(with: profileImageView).startAnimation()
    } else {
      Animators.hideProfileImage(with: profileImageView).startAnimation()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    backgroundImageView.alpha = 0
    backgroundImageView.layer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(70 * Double.pi / 180), 0, 1, 0)
    
    profileImageView.alpha = 0
    profileImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 3)).scaledBy(x: 0.6, y: 0.6).translatedBy(x: -90, y: 0)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Animators.showWidget(with: backgroundImageView).startAnimation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    showProfileImageAnimator = Animators.showProfileImage(with: profileImageView)
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData
    
    completionHandler(NCUpdateResult.newData)
  }
  
  private func shuffle() {
    var count = 0
    
    if !isShuffleStopped {
      if count < diceImages.count {
        diceImageView.image = diceImages.randomItem()
        
        delay(0.1) {
          count += 1
          
          self.shuffle()
        }
      } else {
        count = 0
        self.shuffle()
      }
    } else {
      diceImageView.image = diceImages.randomItem()
    }
  }
  
}

extension TodayViewController: NCWidgetProviding {
  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    if activeDisplayMode == .expanded {
      self.preferredContentSize = CGSize(width: maxSize.width, height: 228)
      
      UIView.animate(withDuration: 0.5) {
        self.likeBackgroundView.alpha = 1
        self.infoStackView.alpha = 1
      }
    } else {
      self.preferredContentSize = maxSize
      
      UIView.animate(withDuration: 0.4) {
        self.likeBackgroundView.alpha = 0
        self.infoStackView.alpha = 0
      }
    }
  }
}
