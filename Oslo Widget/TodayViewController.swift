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
import Alamofire
import PromiseKit
import Kingfisher

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
  @IBOutlet var profileVisualEffectView: UIVisualEffectView!
  @IBOutlet var likeLabel: UILabel!
  
  private let diceImages = [#imageLiteral(resourceName: "Dice1"), #imageLiteral(resourceName: "Dice2"), #imageLiteral(resourceName: "Dice3"), #imageLiteral(resourceName: "Dice4"), #imageLiteral(resourceName: "Dice5"), #imageLiteral(resourceName: "Dice6")]
  private var isShuffleStopped = true
  private var loaderData: Data!
  private var photo: Photo!
  private var statistics: Statistics!
  
  @IBAction func likeItButton(_ sender: Any) {
    if let token = Token.getToken() {
      guard let photoIsLiked = photo.isLike,
        let photoID = photo.id else { return }
      
      if !photoIsLiked {
        brokenHeartImageView.image = #imageLiteral(resourceName: "heart-liked")
        likeLabel.text = localize(with: "Unlike it")
        
        photo.isLike = !photoIsLiked
        
        _ = Alamofire.request(Constants.Base.UnsplashAPI + "/photos/" + photoID + "/like",
                              method: HTTPMethod.post,
                              headers: ["Authorization": "Bearer " + token])
      } else {
        brokenHeartImageView.image = #imageLiteral(resourceName: "broken-heart")
        likeLabel.text = localize(with: "like it")
        
        photo.isLike = !photoIsLiked
        
        _ = Alamofire.request(Constants.Base.UnsplashAPI + "/photos/" + photoID + "/like",
                              method: HTTPMethod.delete,
                              headers: ["Authorization": "Bearer " + token])
      }
    } else {
      let url = URL(string: "Oslo://Login")!
      extensionContext?.open(url)
    }
  }
  
  @IBAction func nextLuckButton(_ sender: Any) {
    if !isShuffleStopped {
      return
    } else {
      isShuffleStopped = false
      
      getImage()
      
      shuffle()
    }
  }
  
  @IBAction func showProfileImageButtonDidPressed(_ sender: Any) {
    if profileImageView.alpha == 0 {
      profileVisualEffectView.effect = UIBlurEffect(style: .light)
      Animators.showProfileImage(with: profileImageView).startAnimation()
    } else {
      profileVisualEffectView.effect = UIBlurEffect(style: .extraLight)
      Animators.hideProfileImage(with: profileImageView).startAnimation()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    likeBackgroundView.alpha = 0
    infoStackView.alpha = 0
    profileImageView.alpha = 0
    profileImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 3)).scaledBy(x: 0.6, y: 0.6).translatedBy(x: -90, y: 0)

    if #available(iOSApplicationExtension 10.0, *) {
      extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    self.preferredContentSize.height = 228
    
    getImage()
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
  
  private func load() -> Promise<Photo> {
    return Promise { fulfill, reject in
      NetworkService.getJson(with: Constants.Base.UnsplashAPI + Constants.Base.Random,
                             parameters: ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]).then { dict -> Void in
                              guard let photo = Photo(json: dict) else { return }
                              
                              fulfill(photo)
      }.catch(execute: reject)
    }
  }
  
  private func loadStatistics(with id: String) -> Promise<Statistics> {
    return Promise { fulfill, reject in
      NetworkService.getJson(with: Constants.Base.UnsplashAPI + "/photos/" + id + "/stats",
                             parameters: ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]).then { dict -> Void in
                              guard let statisticsInfoData = Statistics(json: dict) else { return }
                              
                              fulfill(statisticsInfoData)
      }.catch(execute: reject)
    }
  }
  
  fileprivate func getImage() {
    _ = load().then(on: DispatchQueue.main) { photo -> Void in
      self.photo = photo
      
      guard let photoImageURL = URL(string: photo.imageURL!),
        let profileImageURL = URL(string: photo.profileImageURL!),
        let id = photo.id,
        let isLiked = photo.isLike else { return }
      
      if isLiked {
        self.brokenHeartImageView.image = #imageLiteral(resourceName: "heart-liked")
        self.likeLabel.text = localize(with: "Unlike it")
      } else {
        self.brokenHeartImageView.image = #imageLiteral(resourceName: "broken-heart")
        self.likeLabel.text = localize(with: "Like it")
      }
      
      _ = self.loadStatistics(with: id).then { statisticsInfo -> Void in
        self.viewCountLabel.text = "\(statisticsInfo.views!)"
        self.downloadCountLabel.text = "\(statisticsInfo.downloads!)"
      }
      
      self.backgroundImageView.kf.setImage(with: photoImageURL, options: [.transition(.fade(0.2))])
      self.profileImageView.kf.setImage(with: profileImageURL, options: [.transition(.fade(0.2))])
      
      self.isShuffleStopped = true
    }
  }
  
}

extension TodayViewController {
  func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
    return UIEdgeInsets.zero
  }
}

extension TodayViewController: NCWidgetProviding {
  @available(iOSApplicationExtension 10.0, *)
  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    if activeDisplayMode == .expanded {
      self.preferredContentSize = CGSize(width: maxSize.width, height: 228)
      
      UIView.animate(withDuration: 0.25) {
        self.likeBackgroundView.alpha = 1
        self.infoStackView.alpha = 1
      }
    } else if activeDisplayMode == .compact {
      self.preferredContentSize = maxSize
      
      UIView.animate(withDuration: 0.25) {
        self.likeBackgroundView.alpha = 0
        self.infoStackView.alpha = 0
      }
    }
  }
}
