//
//  LikedPhotoCollectionViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 01/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit
import PromiseKit
import Alamofire
import Kingfisher

class LikedPhotosCollectionViewController: UICollectionViewController {
  var userName: String = ""
  var likedTotalCount: Int = 0
  
  fileprivate var width: CGFloat = 0.0
  fileprivate var photoCache = NSCache<NSString, UIImage>()
  fileprivate var likedPhotos = [Photo]()
  fileprivate var downloadedLikedPhotos = [UIImage?]()
  fileprivate var currentLikedPhotoPage = 1
  
  @IBOutlet var likedPhotosCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentLikedPhotoPage = 1
    
    retryLoad()
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return likedPhotos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedPhotoCell", for: indexPath) as! LikedPhotoCollectionViewCell
    
    cell.likedPhotoImageView.image = nil
    
    let photoURLString = likedPhotos[indexPath.row].imageURL
    
    if let photoURL = URL(string: photoURLString) {
      cell.likedPhotoImageView.kf.setImage(with: photoURL, options: [.transition(.fade(0.2))]) { (image, error, cacheType, imageUrl) in
        self.downloadedLikedPhotos[indexPath.row] = image
      }
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == likedPhotos.count - 1  && indexPath.row != likedTotalCount - 1 {
      currentLikedPhotoPage += 1
      
      _ = load(with: currentLikedPhotoPage).then(on: DispatchQueue.main) { _ in
        self.likedPhotosCollectionView.reloadData()
      }
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier: "PhotoSegue", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PhotoSegue" {
      if let selectedIndexPath = likedPhotosCollectionView.indexPathsForSelectedItems?[0].row,
        let destinationViewController = segue.destination as? PersonalPhotoViewController {
        destinationViewController.photo = likedPhotos[selectedIndexPath]
        destinationViewController.personalPhoto = downloadedLikedPhotos[selectedIndexPath]
        
        if let photosTableViewController = navigationController?.viewControllers[0] as? PhotosTableViewController {
          destinationViewController.delegate = photosTableViewController
        }
      }
    }
  }
  
  func load(with page: Int = 1) -> Promise<[Photo]> {
    let urlString = Constants.Base.UnsplashAPI + "/users/\(userName)/likes"
    
    return Promise { fulfill, reject in
      NetworkService.getPhotosJson(with: urlString,
                             parameters: ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896",
                                          "page": page],
                             headers: ["Authorization": "Bearer " + Token.getToken()!]).then { dicts -> Void in
                              for dict in dicts {
                                OperationService.parseJsonWithPhotoData(dict) { photo in
                                  self.likedPhotos.append(photo)
                                  self.downloadedLikedPhotos.append(nil)
                                }
                              }
                              
                              fulfill(self.likedPhotos)
      }.catch(execute: reject)
    }
  }
  
  func retryLoad() {
    if userName != "" {
      _ = load().then(on: DispatchQueue.main) { _ in
        self.likedPhotosCollectionView.reloadData()
      }
      
      return
    } else {
      delay(1.0) {
        self.retryLoad()
      }
    }
  }
}

extension LikedPhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.width, height: self.width)
  }
}

extension LikedPhotosCollectionViewController: PassDataDelegate {
  func pass(userName: String, photosCount: Int) {
    self.userName = userName
    self.likedTotalCount = photosCount
  }
  
  func pass(width: CGFloat) {
    self.width = width
  }
}
