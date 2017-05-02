//
//  RaccoonViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 02/05/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit

class RaccoonViewController: UIViewController {
  @IBOutlet var raccoonFaceImageView: UIImageView!
  @IBOutlet var raccoonWordsLabel: UILabel!
  @IBOutlet var hamburgerAndChips: UIStackView! = {
    let stackView = UIStackView()
    
    if stackView.gestureRecognizers == nil {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showIAPController))
      stackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    return stackView
  }()
  @IBOutlet var ChikenAndCoke: UIStackView! = {
    let stackView = UIStackView()
    
    if stackView.gestureRecognizers == nil {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showIAPController))
      stackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    return stackView
  }()
  @IBOutlet var LollipopAndCoffee: UIStackView! = {
    let stackView = UIStackView()
    
    if stackView.gestureRecognizers == nil {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showIAPController))
      stackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    return stackView
  }()
  @IBOutlet weak var mealsView: UIView!
  @IBOutlet weak var cancelButton: UIButton!
  
  private var raccoonWords = [
    "Oh, you found me",
    "Though I raccoon, I developer",
    "I quite starve...",
    "buy me food, give you gift"
  ]
  
  private var count = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mealsView.alpha = 0
    cancelButton.alpha = 0
    
    
  }
  
  @IBAction func nextDialog(_ sender: Any) {
    checkDialogPosition()
  }
  
  @IBAction func cancelFed(_ sender: Any) {
    raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-starved")
    raccoonWordsLabel.text = "Maybe I find someone else"
    
    count = 0
    
    delay(2) {
      self.dismiss(animated: true)
    }
  }
  
  private func checkDialogPosition() {
    if count == 3 {
      mealsView.alpha = 1
      cancelButton.alpha = 1
    }
    
    if count < raccoonWords.count {
      raccoonWordsLabel.text = raccoonWords[count]
      count += 1
    }
  }
  
  func showIAPController() {
    
  }

}

