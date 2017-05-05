//
//  IAPHelper.swift
//  Oslo
//
//  Created by hippo_san on 03/05/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHelper : NSObject  {
  fileprivate let productIdentifiers: Set<ProductIdentifier>
  fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
  fileprivate var productsRequest: SKProductsRequest?
  fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
  
  public let loadingIcon: UIActivityIndicatorView = {
    let activityView = UIActivityIndicatorView()
    activityView.color = UIColor(red:0.80, green:0.76, blue:0.99, alpha:1.00)
    activityView.hidesWhenStopped = true
    
    return activityView
  }()
  
  public init(productIds: Set<ProductIdentifier>) {
    productIdentifiers = productIds
    for productIdentifier in productIds {
      let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      } else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    
    super.init()
    
    SKPaymentQueue.default().add(self)
  }
}

// MARK: - StoreKit API

extension IAPHelper {
  
  public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler
    
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest!.delegate = self
    productsRequest!.start()
  }
  
  public func buyProduct(_ product: SKProduct) {
    loadingIcon.startAnimating()
    
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
  public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  public func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

extension IAPHelper: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()
    
    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
  }
  
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }
  
  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

extension IAPHelper: SKPaymentTransactionObserver {
  
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
      case .failed:
        fail(transaction: transaction)
      case .restored:
        restore(transaction: transaction)
      case .deferred: break
      case .purchasing:
        loadingIcon.startAnimating()
      }
    }
  }
  
  private func complete(transaction: SKPaymentTransaction) {
    deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
    
    loadingIcon.stopAnimating()
  }
  
  private func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
    
    deliverPurchaseNotificationFor(identifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
    
    loadingIcon.stopAnimating()
  }
  
  private func fail(transaction: SKPaymentTransaction) {
    loadingIcon.stopAnimating()
    
    if let transactionError = transaction.error as NSError? {
      if transactionError.code != SKError.paymentCancelled.rawValue {
        print("Transaction Error: \(String(describing: transaction.error?.localizedDescription))")
      }
    }
    
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  private func deliverPurchaseNotificationFor(identifier: String?) {
    guard let identifier = identifier else { return }
    
    purchasedProductIdentifiers.insert(identifier)
    UserDefaults.standard.set(true, forKey: identifier)
    UserDefaults.standard.synchronize()
    NotificationCenter.default.post(name: Constants.NotificationName.IAPHelperPurchaseNotification, object: identifier)
  }
}
