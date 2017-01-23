//
//  PublishedPhotoCollectionViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 01/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class PublishedPhotosCollectionViewController: UICollectionViewController {
  var userName: String = ""
  var publishedTotalCount: Int = 0
  
  fileprivate var width: CGFloat = 0.0
  fileprivate var publishedPhotos = [Photo]()
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
    
    let photoURLString = publishedPhotos[indexPath.row].imageURL
    
    if let photoURL = URL(string: photoURLString) {
      if let cachedImage = self.photoCache.object(forKey: photoURLString as NSString) {
        cell.publishedPhotoImageView.image = cachedImage
        
        self.downloadedPublishedPhotos[indexPath.row] = cachedImage
      } else {
        NetworkService.image(with: photoURL) { image in
          
          self.photoCache.setObject(image, forKey: photoURLString as NSString)
          
          self.downloadedPublishedPhotos[indexPath.row] = image
          
          if let updateCell = collectionView.cellForItem(at: indexPath) as? PublishedPhotoCollectionViewCell {
            updateCell.publishedPhotoImageView.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
              updateCell.publishedPhotoImageView.alpha = 1
              updateCell.publishedPhotoImageView.image = image
            }
          }
        }
      }
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    cell.layoutMargins = UIEdgeInsets.zero
    cell.preservesSuperviewLayoutMargins = false
    
    
    if indexPath.row == publishedPhotos.count - 1 && indexPath.row != publishedTotalCount - 1 {
      currentPublishedPhotoPage += 1
      
      load(with: currentPublishedPhotoPage)
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
  
  func load(with page: Int = 1) {
    let urlString = Constants.Base.UnsplashAPI + "/users/\(userName)/photos"
    let url = URL(string: urlString)!
    
    NetworkService.request(url: url,
                           method: NetworkService.HTTPMethod.GET,
                           parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
                                        ["page": page as AnyObject]],
                           headers: ["Authorization": "Bearer " + Token.getToken()!]) { jsonData in
                                          OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>]) { photo in
                                            self.publishedPhotos.append(photo)
                                            self.downloadedPublishedPhotos.append(nil)
                                          }
                                          
                                          OperationQueue.main.addOperation {
                                            self.publishedPhotosCollectionView.reloadData()
                                          }
    }
  }
  
  func retryLoad() {
    if userName != "" {
      load()
      
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
