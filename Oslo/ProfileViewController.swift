//
//  ProfileViewController.swift
//  Oslo
//
//  Created by hippo_san on 6/24/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit
import Kingfisher
import Alamofire
import PromiseKit
import Gloss

class ProfileViewController: UIViewController {
  
  var photo: Photo!
  var profileImage: UIImage!
  
  fileprivate var personalPhotos = [Photo]() {
    didSet {
      downloadedPersonalPhotos = [UIImage?](repeating: nil, count: personalPhotos.count)
    }
  }
  fileprivate var totalPhotosCount: Int = 0
  fileprivate var downloadedPersonalPhotos = [UIImage?]()
  fileprivate var currentPage = 1
  
  fileprivate var loadingView: LoadingView! {
    didSet {
      loadingView.frame = collectionView.bounds
      loadingView.frame.size.width = self.view.frame.size.width
    }
  }
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var bioLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet var portfolioImage: UIImageView!
  @IBOutlet var locationImage: UIImageView!
  @IBOutlet var portfolioName: UIButton!
  @IBOutlet var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    avatarImageView.image = profileImage
    userLabel.text = photo.name
    bioLabel.text = photo.bio
    
    if let photoLocation = photo.location {
      locationLabel.text = photoLocation
    } else {
      locationImage.alpha = 0
    }
    
    if let photoPortfolioURL = photo.portfolioURL {
      if photoPortfolioURL.contains("instagram.com") {
        portfolioImage.image = #imageLiteral(resourceName: "instagram")
        let instagramName = photoPortfolioURL.components(separatedBy: "/")
        
        portfolioName.setTitle(instagramName[3], for: .normal)
      } else {
        portfolioImage.image = #imageLiteral(resourceName: "portfolio")
        portfolioName.setTitle(localize(with: "Website"), for: .normal)
      }
    } else {
      portfolioImage.alpha = 0
    }
    
    currentPage = 1
    
    loadingView = LoadingView()
    collectionView.addSubview(loadingView)
    
    _ = load().then(on: DispatchQueue.main) { dicts -> Void in
      self.collectionView.reloadData()
      
      self.loadingView.removeFromSuperview()
    }
  }
  
  func load(with page: Int = 1) -> Promise<[Photo]> {
    return Promise { fulfill, reject in
      guard let userName = photo.userName else {
        let error = NSError(domain: "ziyideas.com.PromiseKit", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        reject(error)
        return
      }
      
      let urlString = Constants.Base.UnsplashAPI + "/users/\(userName)/photos"
      
      if let token = Token.getToken() {
        NetworkService.getPhotosJson(with: urlString,
                               parameters: [
          "client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896",
          "page": page
          ], headers: ["Authorization": "Bearer " + token]).then { dicts -> Void in
            
            guard let firstData = dicts[0] as? Dictionary<String, Any>,
              let user = firstData["user"] as? [String: Any],
              let totalPhotos = user["total_photos"] as? Int else {
                let error = NSError(domain: "ziyideas.com.PromiseKit", code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                reject(error)
                return
            }
            
            self.totalPhotosCount = totalPhotos
            
            guard let photos = [Photo].from(jsonArray: dicts as! [JSON]) else { return }
            self.personalPhotos.append(contentsOf: photos)
            
            fulfill(self.personalPhotos)
        }.catch(execute: reject)
      } else {
        NetworkService.getPhotosJson(with: urlString,
                               parameters: ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]).then { dicts -> Void in
            guard let firstData = dicts[0] as? Dictionary<String, Any>,
              let user = firstData["user"] as? [String: Any],
              let totalPhotos = user["total_photos"] as? Int else {
                let error = NSError(domain: "ziyideas.com.PromiseKit", code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                reject(error)
                return
            }
            
            self.totalPhotosCount = totalPhotos
            
            guard let photos = [Photo].from(jsonArray: dicts as! [JSON]) else { return }
            self.personalPhotos.append(contentsOf: photos)
            
            fulfill(self.personalPhotos)
          }.catch(execute: reject)
      }
    }
  }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return personalPhotos.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonalPhoto", for: indexPath) as! ProfileCollectionViewCell
    
    cell.personalPhotoImageView.image = nil
    
    if let photoURLString = personalPhotos[indexPath.row].imageURL,
      let photoURL = URL(string: photoURLString) {
      cell.personalPhotoImageView.kf.setImage(with: photoURL, options: [.transition(.fade(0.2))]) { (image, error, cacheType, imageUrl) in
        self.downloadedPersonalPhotos[indexPath.row] = image
      }
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == personalPhotos.count - 1 && indexPath.row != totalPhotosCount - 1 {
      currentPage += 1
      
      _ = load(with: currentPage).then(on: DispatchQueue.main) { dicts -> Void in
        self.collectionView.reloadData()
        
        self.loadingView.removeFromSuperview()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier: "PhotoSegue", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PhotoSegue" {
      if let selectedIndexPath = collectionView.indexPathsForSelectedItems?[0].row,
        let destinationViewController = segue.destination as? PersonalPhotoViewController {
        destinationViewController.photo = personalPhotos[selectedIndexPath]
        destinationViewController.personalPhoto = downloadedPersonalPhotos[selectedIndexPath]
      }
    } else if segue.identifier == "PortfolioSegue" {
      if let destinationViewController = segue.destination as? PortfolioWebViewController {
        guard let photoName = photo.name, let portfolioURL = photo.portfolioURL else { return }
        destinationViewController.navigationItem.title = localizedFormat(with: "%@'s website", and: photoName)
        destinationViewController.portfolioURL = portfolioURL
      }
    }
  }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
  }
}
