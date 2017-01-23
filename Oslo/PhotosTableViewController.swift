//
//  PhotosTableViewController.swift
//  Oslo
//
//  Created by hippo_san on 6/12/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController {
  @IBOutlet weak var userBarButton: UIBarButtonItem!
  
  fileprivate var photos = [Photo]()
  fileprivate var personalPhotos = [UIImage?]()
  fileprivate var profileImages = [UIImage?]()
  fileprivate var photoCache = NSCache<NSString, UIImage>()
  
  private var loadingView: LoadingView! {
    didSet {
      loadingView.frame.origin = self.view.frame.origin
      loadingView.frame.size.width = self.view.frame.size.width
    }
  }
  
  lazy var feedRefreshControl: UIRefreshControl = {
    let feedRefreshControl = UIRefreshControl()
    feedRefreshControl.tintColor = UIColor.clear
    feedRefreshControl.addTarget(self, action: #selector(load(with:)), for: .valueChanged)
    
    self.loadingView = LoadingView()
    self.loadingView.frame.size.height = feedRefreshControl.frame.size.height
    
    feedRefreshControl.addSubview(self.loadingView)
    
    return feedRefreshControl
  }()
  
  fileprivate var currentPage = 1
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if Token.getToken() != nil {
      userBarButton.tintColor = UIColor.colorWithRGB(red: 255, green: 213, blue: 40, alpha: 1.0)
    } else {
      userBarButton.tintColor = UIColor.colorWithRGB(red: 255, green: 255, blue: 255, alpha: 0.8)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = localize(with: "Feature")
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    
    currentPage = 1
    
    tableView.refreshControl = feedRefreshControl
    
    load()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let photo = photos[indexPath.row]
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalPhoto", for: indexPath) as! PhotoTableViewCell
    cell.delegate = self
    
    cell.photoImageView.image = nil
    cell.userImageView.image = nil
    
    if let photoURL = URL(string: photo.imageURL) {
      if let cachedImage = self.photoCache.object(forKey: photo.imageURL as NSString) {
        cell.photoImageView.image = cachedImage
      } else {
        NetworkService.image(with: photoURL) { image in
          self.photoCache.setObject(image, forKey: photo.imageURL as NSString)
          
          self.personalPhotos[indexPath.row] = image
          
          if let updateCell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell {
            updateCell.photoImageView.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
              updateCell.photoImageView.alpha = 1
              updateCell.photoImageView.image = image
            }
            
          }
        }
      }
    }
    
    if let profileURL = URL(string: photo.profileImageURL) {
      if let cachedImage = self.photoCache.object(forKey: photo.profileImageURL as NSString) {
        cell.userImageView.image = cachedImage
      } else {
        NetworkService.image(with: profileURL) { image in
          self.photoCache.setObject(image, forKey: photo.profileImageURL as NSString)
          
          self.profileImages[indexPath.row] = image
          
          if let updateCell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell {
            updateCell.userImageView.image = image
          }
        }
      }
    }

    cell.userLabel.setTitle(photo.name, for: .normal)
    cell.isLike = photo.isLike
    cell.heartCountLabel.text = "\(photo.heartCount)"
    cell.photoID = photo.id
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == photos.count - 1 {
      currentPage += 1
      
      load(with: currentPage)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.width * 0.7
  }
  
  @IBAction func userBarButtonDidPressed(_ sender: Any) {
    
    if Token.getToken() == nil {
      let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
      present(loginViewController, animated: true)
    } else {
      let meViewController = storyboard?.instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
      show(meViewController, sender: sender)
    }
    
  }
  
  func load(with page: Int = 1) {
    feedRefreshControl.beginRefreshing()
    
    let url = URL(string: Constants.Base.UnsplashAPI + Constants.Base.Curated)!
    
    if Token.getToken() != nil {
      NetworkService.request(url: url, method: NetworkService.HTTPMethod.GET,
                             parameters: [
                              Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
                              ["page": page as AnyObject]
      ], headers: ["Authorization": "Bearer " + Token.getToken()!]) { jsonData in
        
        OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>]) { photo in
          self.photos.append(photo)
          self.personalPhotos.append(nil)
          self.profileImages.append(nil)
        }
      
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
          self.feedRefreshControl.endRefreshing()
        }
      }
    } else {
      NetworkService.request(url: url, method: NetworkService.HTTPMethod.GET,
                             parameters: [
                              Constants.Parameters.ClientID as Dictionary<String, AnyObject>,
                              ["page": page as AnyObject]
                             ]) { jsonData in
        OperationService.parseJsonWithPhotoData(jsonData as! [Dictionary<String, AnyObject>]) { photo in
          self.photos.append(photo)
          self.personalPhotos.append(nil)
          self.profileImages.append(nil)
        }
        
        OperationQueue.main.addOperation {
          self.tableView.reloadData()
          self.feedRefreshControl.endRefreshing()
        }
      }
    }
  }
  
  func getCurrentCellRow(sender: Any?) -> IndexPath? {
    if let sourceSender = sender as? UITapGestureRecognizer,
      let cellView = sourceSender.view?.superview,
      let cell = cellView.superview as? PhotoTableViewCell {
      let selectedIndexPath = tableView.indexPath(for: cell)!
      
      return selectedIndexPath
    } else if let sourceSender = sender as? UIButton {
      let buttonPosition = sourceSender.convert(CGPoint.zero, to: tableView)
      let selectedIndexPath = tableView.indexPathForRow(at: buttonPosition)!
      
      return selectedIndexPath
    }
    
    return nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let selectedIndexPathRow = getCurrentCellRow(sender: sender)?.row else { return }
    
    if segue.identifier == "ProfileSegue" {
      if let destinationViewController = segue.destination as? ProfileViewController {
        destinationViewController.photo = photos[selectedIndexPathRow]
        destinationViewController.profileImage = profileImages[selectedIndexPathRow]
        destinationViewController.navigationItem.title = photos[selectedIndexPathRow].name
      }
    } else if segue.identifier == "PhotoSegue" {
        if let destinationViewController = segue.destination as? PersonalPhotoViewController {
          destinationViewController.photo = photos[selectedIndexPathRow]
          destinationViewController.personalPhoto = personalPhotos[selectedIndexPathRow]
          destinationViewController.delegate = self
        }
    }
  }
}

extension PhotosTableViewController: PhotoTableViewCellDelegate {
  func tapToPerformSegue(_ sender: Any) {
    if let tag = (sender as AnyObject).view?.tag {
      switch tag {
      case 0:
        performSegue(withIdentifier: "PhotoSegue", sender: sender)
        
      case 1:
        performSegue(withIdentifier: "ProfileSegue", sender: sender)
        
      default:
        break
      }
    }
  }
  
  func heartButtonDidPressed(sender: Any, isLike: Bool, heartCount: Int) {
    if Token.getToken() != nil {
      if let selectedIndexPath = getCurrentCellRow(sender: sender) {
        photos[selectedIndexPath.row].isLike = isLike
        photos[selectedIndexPath.row].heartCount = heartCount
      }
    } else {
      let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
      present(loginViewController, animated: true)
    }
  }
}

extension PhotosTableViewController: PersonalPhotoViewControllerDelegate {
  func heartButtonDidPressed(with photoID: String, isLike: Bool, heartCount: Int) {
    if let indexPathRow = photos.index(where: { $0.id == photoID }) {
      photos[indexPathRow].isLike = isLike
      photos[indexPathRow].heartCount = heartCount
      
      let indexPath = IndexPath(row: indexPathRow, section: 0)
      
      tableView.reloadRows(at: [indexPath], with: .automatic)
    }
  }
}
