//
//  RaccoonViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 02/05/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import UIKit
import StoreKit

import OsloKit
import Device_swift

class RaccoonViewController: UIViewController {
  @IBOutlet var raccoonFaceImageView: UIImageView!
  @IBOutlet var raccoonWordsLabel: UILabel!
  @IBOutlet var hamburgerAndChips: UIStackView!
  @IBOutlet var chickenAndCoke: UIStackView!
  @IBOutlet var lollipopAndCoffee: UIStackView!
  @IBOutlet weak var mealsView: UIView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet var hamburgerAndChipsPrice: UILabel!
  @IBOutlet var chickenAndCokePrice: UILabel!
  @IBOutlet var lollipopAndCoffeePrice: UILabel!
  @IBOutlet var nextDialogButton: UIButton!
  @IBOutlet var mealsStackView: UIStackView!
  @IBOutlet var mealsTitleLabel: UILabel!
  @IBOutlet var dialogView: UIView!
  @IBOutlet var dialogBackground: UIImageView!
  
  private let priceFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    
    formatter.formatterBehavior = .behavior10_4
    formatter.numberStyle = .currency
    
    return formatter
  }()
  
  private let raccoonStore = IAPHelper(productIds: [
    Constants.IAPIdentifiers.hamburgerAndChips,
    Constants.IAPIdentifiers.chickenAndCoke,
    Constants.IAPIdentifiers.lollipopAndCoffee
    ])
  
  private var raccoonWords = [
    localize(with: "Oh, you found me"),
    localize(with: "Though I raccoon, I developer"),
    localize(with: "I quite starve..."),
    localize(with: "buy me food, give you gift"),
    localize(with: "As gift, see app's icon your home screen")
  ]
  
  private var purchasedMeal: Meals = .hamburgerAndChips
  
  private var count = 1
  
  private var products: [SKProduct]? {
    didSet {
      guard let raccoonProducts = products else { return }
      
      for product in raccoonProducts {
        if SKPaymentQueue.canMakePayments() {
          priceFormatter.locale = product.priceLocale
          
          switch product.productIdentifier {
          case Constants.IAPIdentifiers.hamburgerAndChips:
            hamburgerAndChipsPrice.text = priceFormatter.string(from: product.price)
          case Constants.IAPIdentifiers.chickenAndCoke:
            chickenAndCokePrice.text = priceFormatter.string(from: product.price)
          case Constants.IAPIdentifiers.lollipopAndCoffee:
            lollipopAndCoffeePrice.text = priceFormatter.string(from: product.price)
          default: break
          }
        } else {
          hamburgerAndChipsPrice.text = localize(with: "Not available")
          chickenAndCokePrice.text = localize(with: "Not available")
          lollipopAndCoffeePrice.text = localize(with: "Not available")
        }
      }
    }
  }
  
  private var raccoonIsFedThisTime = false
  
  override func viewDidLoad() {
    super.viewDidLoad()

    raccoonStore.loadingIcon.center = self.view.center
    raccoonStore.loadingIcon.stopAnimating()
    self.view.addSubview(raccoonStore.loadingIcon)

    mealsView.alpha = 0
    cancelButton.alpha = 0
    raccoonWordsLabel.text = raccoonWords[0]
    
    transformMealsLabel()
    
    if hamburgerAndChips.gestureRecognizers == nil {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buyRaccoonProduct(with:)))
      hamburgerAndChips.addGestureRecognizer(tapGestureRecognizer)
    }
    
    if chickenAndCoke.gestureRecognizers == nil {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buyRaccoonProduct(with:)))
      chickenAndCoke.addGestureRecognizer(tapGestureRecognizer)
    }
    
    if lollipopAndCoffee.gestureRecognizers == nil {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buyRaccoonProduct(with:)))
      lollipopAndCoffee.addGestureRecognizer(tapGestureRecognizer)
    }
    
    if UserDefaults.standard.bool(forKey: Constants.IAPIdentifiers.hamburgerAndChips) == true {
      hamburgerAndChips.removeFromSuperview()
    }
    
    if UserDefaults.standard.bool(forKey: Constants.IAPIdentifiers.chickenAndCoke) == true {
      chickenAndCoke.removeFromSuperview()
    }
    
    if UserDefaults.standard.bool(forKey: Constants.IAPIdentifiers.lollipopAndCoffee) == true {
      lollipopAndCoffee.removeFromSuperview()
    }
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handlePurchaseNotification(_:)),
                                           name: Constants.NotificationName.IAPHelperPurchaseNotification, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-found")
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    raccoonStore.requestProducts { success, products in
      if success {
        self.products = products!
      }
    }
  }
  
  @IBAction func nextDialog(_ sender: Any) {
    checkDialogPosition()
  }
  
  @IBAction func cancelFed(_ sender: Any) {
    mealsView.alpha = 0
    count = 0
    
    if raccoonIsFedThisTime {
      self.dismiss(animated: true)
    } else {
      raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-starved")
      raccoonWordsLabel.text = localize(with: "Maybe I find someone else")
      
      delay(2) {
        self.dismiss(animated: true)
      }
    }
  }
  
  private func checkDialogPosition() {
    if count == 2 {
      raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-panic")
    } else if count == 3 {
      mealsView.alpha = 1
      cancelButton.alpha = 1
      raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-panic")
      nextDialogButton.isUserInteractionEnabled = false
    } else if count == 4  && raccoonWords[4] == localize(with: "As gift, see app's icon your home screen") {
      cancelButton.alpha = 0
      mealsView.alpha = 0
      
      changeAppIcon()
    } else if count == 4 && raccoonWords[4] == localize(with: "Have to update iOS see gift") {
      raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-panic")
    }
    
    if count < raccoonWords.count {
      Animators.nextDialog(with: dialogBackground).startAnimation()
      
      raccoonWordsLabel.text = raccoonWords[count]
      count += 1
    } else {
      self.dismiss(animated: true)
    }
  }
  
  func buyRaccoonProduct(with sender: UITapGestureRecognizer) {
    guard let products = products else { return }
    
    if sender.view?.tag == 0 {
      let product = products.filter { $0.productIdentifier == Constants.IAPIdentifiers.hamburgerAndChips }[0]
      raccoonStore.buyProduct(product)
    } else if sender.view?.tag == 1 {
      
      let product = products.filter { $0.productIdentifier == Constants.IAPIdentifiers.chickenAndCoke }[0]
      raccoonStore.buyProduct(product)
    } else {
      let product = products.filter { $0.productIdentifier == Constants.IAPIdentifiers.lollipopAndCoffee }[0]
      raccoonStore.buyProduct(product)
    }
  }
  
  func handlePurchaseNotification(_ notification: Notification) {
    guard let productID = notification.object as? String else { return }
    
    raccoonIsFedThisTime = true
    nextDialogButton.isUserInteractionEnabled = true
    
    raccoonFaceImageView.image = #imageLiteral(resourceName: "raccoon-fed")
    
    if productID == Constants.IAPIdentifiers.hamburgerAndChips {
      purchasedMeal = .hamburgerAndChips
      raccoonWordsLabel.text = purchasedMeal.description
      
      UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
        self.hamburgerAndChips.alpha = 0
        self.hamburgerAndChips.removeFromSuperview()
        
        self.checkIfMealsAreAvailable()
      })
    } else if productID == Constants.IAPIdentifiers.chickenAndCoke {
      purchasedMeal = .chikenAndCoke
      raccoonWordsLabel.text = purchasedMeal.description
      
      UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
        self.chickenAndCoke.alpha = 0
        self.chickenAndCoke.removeFromSuperview()
        
        self.checkIfMealsAreAvailable()
      })
    } else {
      purchasedMeal = .lollipopAndCoffee
      raccoonWordsLabel.text = purchasedMeal.description
      
      UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
        self.lollipopAndCoffee.alpha = 0
        self.lollipopAndCoffee.removeFromSuperview()
        
        self.checkIfMealsAreAvailable()
      })
    }
  }
  
  func checkIfMealsAreAvailable() {
    if mealsStackView.subviews.count == 0 {
      mealsTitleLabel.alpha = 0
    }
  }
  
  private func changeAppIcon() {
    if #available(iOS 10.3, *) {
      let deviceType = UIDevice.current.deviceType
      
      if deviceType.rawValue.contains("iPhone") {
        UIApplication.shared.setAlternateIconName("AlternativeiPhoneIcon")
      } else if deviceType.rawValue.contains("iPad") && !deviceType.rawValue.contains("Pro") {
        UIApplication.shared.setAlternateIconName("AlternativeiPadIcon")
      } else if deviceType.rawValue.contains("iPadPro") {
        UIApplication.shared.setAlternateIconName("AlternativeiPadProIcon")
      }
    } else {
      raccoonWords[4] = localize(with: "Have to update iOS see gift")
    }
  }
  
  private func transformMealsLabel() {
    var transformation = CATransform3DIdentity
    transformation.m12 = -0.2
    
    let concatenatedTransformation = CATransform3DConcat(CATransform3DIdentity, transformation)
    mealsTitleLabel.layer.transform = concatenatedTransformation
  }
  
  private func checkIfRaccoonShouldShow() {
    
  }
}

