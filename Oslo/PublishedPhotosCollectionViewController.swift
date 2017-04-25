//
//  PublishedPhotoCollectionViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 01/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit
import Alamofire
import PromiseKit
import Kingfisher
import Gloss

class PublishedPhotosCollectionViewController: UICollectionViewController {
  var userName: String = ""
  var publishedTotalCount: Int = 0
  
  fileprivate var width: CGFloat = 0.0
  fileprivate var publishedPhotos = [Photo]() {
    didSet {
      downloadedPublishedPhotos = [UIImage?](repeating: nil, count: publishedPhotos.count)
    }
  }
  fileprivate var photoCache = NSCache<NSString, UIImage>()
  fileprivate var downloadedPublishedPhotos = [UIImage?]()
  fileprivate var currentPublishedPhotoPage = 1
  
  @IBOutlet var publishedPhotosCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentPublishedPhotoPage = 1
    
    retryLoad()
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return publishedPhotos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PublishedPhotoCell", for: indexPath) as! PublishedPhotoCollectionViewCell
    
    cell.publishedPhotoImageView.image = nil
    
    if let photoURLString = publishedPhotos[indexPath.row].imageURL,
      let photoURL = URL(string: photoURLString) {
      cell.publishedPhotoImageView.kf.setImage(with: photoURL, options: [.transition(.fade(0.2))]) { (image, error, cacheType, imageUrl) in
        self.downloadedPublishedPhotos[indexPath.row] = image
      }
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    cell.layoutMargins = UIEdgeInsets.zero
    cell.preservesSuperviewLayoutMargins = false
    
    
    if indexPath.row == publishedPhotos.count - 1 && indexPath.row != publishedTotalCount - 1 {
      currentPublishedPhotoPage += 1
      
      _ = load(with: currentPublishedPhotoPage).then(on: DispatchQueue.main) { _ in
        self.publishedPhotosCollectionView.reloadData()
      }
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    performSegue(withIdentifier: "PhotoSegue", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PhotoSegue" {
      if let selectedIndexPath = publishedPhotosCollectionView.indexPathsForSelectedItems?[0].row,
        let destinationViewController = segue.destination as? PersonalPhotoViewController {
        destinationViewController.photo = publishedPhotos[selectedIndexPath]
        destinationViewController.personalPhoto = downloadedPublishedPhotos[selectedIndexPath]
        
        if let photosTableViewController = navigationController?.viewControllers[0] as? PhotosTableViewController {
          destinationViewController.delegate = photosTableViewController
        }
      }
    }
  }
  
  func load(with page: Int = 1) -> Promise<[Photo]> {
    let urlString = Constants.Base.UnsplashAPI + "/users/\(userName)/photos"
    
    return Promise { fulfill, reject in
      NetworkService.getPhotosJson(with: urlString,
                             parameters: [
                              "client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896",
                              "page": page
        ], headers: ["Authorization": "Bearer " + Token.getToken()!]).then { dicts -> Void in
          guard let photos = [Photo].from(jsonArray: dicts as! [JSON]) else { return }
          
          self.publishedPhotos.append(contentsOf: photos)
          
          fulfill(self.publishedPhotos)
      }.catch(execute: reject)
    }
  }
  
  func retryLoad() {
    if userName != "" {
      _ = load().then(on: DispatchQueue.main) { _ in
        self.publishedPhotosCollectionView.reloadData()
      }
      
      return
    } else {
      delay(1.0) {
        self.retryLoad()
      }
    }
  }
}

extension PublishedPhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.width, height: self.width)
  }
}

extension PublishedPhotosCollectionViewController: PassDataDelegate {
  func pass(userName: String, photosCount: Int) {
    self.userName = userName
    self.publishedTotalCount = photosCount
  }
  
  func pass(width: CGFloat) {
    self.width = width
  }
}
