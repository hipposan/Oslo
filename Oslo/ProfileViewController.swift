//
//  ProfileViewController.swift
//  Oslo
//
//  Created by hippo_san on 6/24/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  var photo: Photo!
  var profileImage: UIImage!
  
  fileprivate var personalPhotos = [Photo]()
  fileprivate var totalPhotosCount: Int = 0
  fileprivate var photoCache = NSCache<NSString, UIImage>()
  fileprivate var downloadedPersonalPhotos = [UIImage?]()
  fileprivate var currentPage = 1
  
  private var loadingView: LoadingView! {
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
  @IBOutlet var portfolioName: UIButton!
  @IBOutlet var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    avatarImageView.image = profileImage
    userLabel.text = photo.name
    bioLabel.text = photo.bio
    
    if photo.location != "" {
      locationLabel.text = photo.location
    } else {
      locationLabel.text = localize(with: "No Location")
    }
    
    if photo.portfolioURL.contains("instagram.com") {
      portfolioImage.image = #imageLiteral(resourceName: "instagram")
      let instagramName = photo.portfolioURL.components(separatedBy: "/")
      portfolioName.setTitle(instagramName[3], for: .normal)
    } else {
      portfolioImage.image = #imageLiteral(resourceName: "portfolio")
      portfolioName.setTitle(localize(with: "Website"), for: .normal)
    }
    
    currentPage = 1
    
    loadingView = LoadingView()
    collectionView.addSubview(loadingView)
    
    load()
  }
  
  func load(with page: Int = 1) {
    let urlString = Constants.Base.UnsplashAPI + "/users/\(photo.userName)/photos"
    let url = URL(string: urlString)!
    
    if let token = Token.getToken() {
      NetworkService.request(url: url,
                             method: NetworkService.HTTPMethod.GET,
                             parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
                                         ["page": page as AnyObject]],
                             headers: ["Authorization": "Bearer " + token]) { jsonData in
                              guard let data = (jsonData as? [Dictionary<String, AnyObject>]) else { return }
                              
                              let firstData = data[0]
                              
                              if let user = firstData["user"] as? [String: AnyObject],
                                let totalPhotos = user["total_photos"] as? Int {
                                self.totalPhotosCount = totalPhotos
                              }
                              
                              OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>]) { photo in
                                self.personalPhotos.append(photo)
                                self.downloadedPersonalPhotos.append(nil)
                              }
                              
                              OperationQueue.main.addOperation {
                                self.collectionView.reloadData()
                                
                                self.loadingView.removeFromSuperview()
                              }
      }
    } else {
      NetworkService.request(url: url,
                             method: NetworkService.HTTPMethod.GET,
                             parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>]) { jsonData in
                              guard let data = (jsonData as? [Dictionary<String, AnyObject>]) else { return }
                              
                              let firstData = data[0]
                              
                              if let user = firstData["user"] as? [String: AnyObject],
                                let totalPhotos = user["total_photos"] as? Int {
                                self.totalPhotosCount = totalPhotos
                              }
                              
                              OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>]) { photo in
                                self.personalPhotos.append(photo)
                                self.downloadedPersonalPhotos.append(nil)
                              }
                              
                              OperationQueue.main.addOperation {
                                self.collectionView.reloadData()
                                self.loadingView.removeFromSuperview()
                              }
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
    
    let photoURLString = personalPhotos[indexPath.row].imageURL
    
    if let photoURL = URL(string: photoURLString) {
      if let cachedImage = self.photoCache.object(forKey: photoURLString as NSString) {
        cell.personalPhotoImageView.image = cachedImage
        self.downloadedPersonalPhotos[indexPath.row] = cachedImage
      } else {
        NetworkService.image(with: photoURL) { image in
          self.photoCache.setObject(image, forKey: photoURLString as NSString)
          
          self.downloadedPersonalPhotos[indexPath.row] = image
          
          if let updateCell = collectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell {
            updateCell.personalPhotoImageView.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
              updateCell.personalPhotoImageView.alpha = 1
              updateCell.personalPhotoImageView.image = image
            }
          }
        }
      }
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == personalPhotos.count - 1 && indexPath.row != totalPhotosCount - 1 {
      currentPage += 1
      
      load(with: currentPage)
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
        
        if let photosTableViewController = navigationController?.viewControllers[0] as? PhotosTableViewController {
          destinationViewController.delegate = photosTableViewController
        }
      }
    } else if segue.identifier == "PortfolioSegue" {
      if let destinationViewController = segue.destination as? PortfolioWebViewController {
        destinationViewController.navigationItem.title = localizedFormat(with: "%@'s website", and: photo.name)
        destinationViewController.portfolioURL = photo.portfolioURL
      }
    }
  }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
  }
}
