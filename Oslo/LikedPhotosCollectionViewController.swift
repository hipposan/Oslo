//
//  LikedPhotoCollectionViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 01/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

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
      if let cachedImage = self.photoCache.object(forKey: photoURLString as NSString) {
        cell.likedPhotoImageView.image = cachedImage
        self.downloadedLikedPhotos[indexPath.row] = cachedImage
      } else {
        NetworkService.image(with: photoURL) { image in
          self.photoCache.setObject(image, forKey: photoURLString as NSString)
          
          self.downloadedLikedPhotos[indexPath.row] = image
          
          if let updateCell = collectionView.cellForItem(at: indexPath)  as? LikedPhotoCollectionViewCell {
            updateCell.likedPhotoImageView.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
              updateCell.likedPhotoImageView.alpha = 1
              updateCell.likedPhotoImageView.image = image
            }
          }
        }
      }
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == likedPhotos.count - 1  && indexPath.row != likedTotalCount - 1 {
      currentLikedPhotoPage += 1
      
      load(with: currentLikedPhotoPage)
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
  
  func load(with page: Int = 1) {
    let urlString = Constants.Base.UnsplashAPI + "/users/\(userName)/likes"
    let url = URL(string: urlString)!
    
    NetworkService.request(url: url,
                           method: NetworkService.HTTPMethod.GET,
                           parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
                                        ["page": page as AnyObject]],
                           headers: ["Authorization": "Bearer " + Token.getToken()!]) { jsonData in
                                          OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>]) { photo in
                                            self.likedPhotos.append(photo)
                                            self.downloadedLikedPhotos.append(nil)
                                          }
                                          
                                          OperationQueue.main.addOperation {
                                            self.likedPhotosCollectionView.reloadData()
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
