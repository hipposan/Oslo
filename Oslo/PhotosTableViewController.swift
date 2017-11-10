//
//  PhotosTableViewController.swift
//  Oslo
//
//  Created by hippo_san on 6/12/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit
import Kingfisher
import Alamofire
import PromiseKit
import Gloss

class PhotosTableViewController: UITableViewController {
  @IBOutlet weak var userBarButton: UIBarButtonItem!
  
  fileprivate var photos = [Photo]() {
    didSet {
      personalPhotos = [UIImage?](repeating: nil, count: photos.count)
      profileImages = [UIImage?](repeating: nil, count: photos.count)
    }
  }
  fileprivate var personalPhotos = [UIImage?]()
  fileprivate var profileImages = [UIImage?]()
  
  private var loadingView: LoadingView! {
    didSet {
      loadingView.frame.origin = self.view.frame.origin
      loadingView.frame.size.width = self.view.frame.size.width
    }
  }
  
  lazy var feedRefreshControl: UIRefreshControl = {
    let feedRefreshControl = UIRefreshControl()
    feedRefreshControl.tintColor = UIColor.clear
    feedRefreshControl.addTarget(self, action: #selector(pullToLoad), for: .valueChanged)
    
    self.loadingView = LoadingView()
    self.loadingView.frame.size.height = feedRefreshControl.frame.size.height
    
    feedRefreshControl.addSubview(self.loadingView)
    
    return feedRefreshControl
  }()
  
  fileprivate var currentPage = 1
  fileprivate var raccoonImageView: UIImageView? {
    didSet {
      if UserDefaults.standard.bool(forKey: Constants.IAPIdentifiers.hamburgerAndChips) == true
        && UserDefaults.standard.bool(forKey: Constants.IAPIdentifiers.chickenAndCoke) == true
        && UserDefaults.standard.bool(forKey: Constants.IAPIdentifiers.lollipopAndCoffee) == true {
        raccoonImageView = nil
      } else {
        raccoonImageView?.image = #imageLiteral(resourceName: "raccoon")
        raccoonImageView?.contentMode = .scaleAspectFill
        raccoonImageView?.isUserInteractionEnabled = true
        
        if raccoonImageView?.gestureRecognizers == nil {
          let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(raccoonFound(_:)))
          raccoonImageView?.addGestureRecognizer(tapGestureRecognizer)
        }
      }
    }
  }
  
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(toggleLikedStatus(_:)), name: Constants.NotificationName.likeSendNotification, object: nil)
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    
    currentPage = 1
    
    tableView.refreshControl = feedRefreshControl
    
    self.raccoonImageView = UIImageView()
    if let imageView = self.raccoonImageView, let navigationBar = self.navigationController?.navigationBar {
      imageView.frame = CGRect(x: navigationBar.center.x + 1 / 4 * navigationBar.frame.size.width, y: navigationBar.frame.height - 21, width: 60, height: 40)
      
      Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [unowned self] _ in
        self.blink(with: imageView)
      }
      
      navigationBar.addSubview(imageView)
    }
    
    pullToLoad()
  }
  
  private func blink(with imageView: UIImageView) {
    imageView.image = #imageLiteral(resourceName: "raccoon")
    
    delay(1.5) {
      imageView.image = #imageLiteral(resourceName: "raccoon-close-eyes")
      
      delay(0.1) {
        imageView.image = #imageLiteral(resourceName: "raccoon")
        
        delay(0.1) {
          imageView.image = #imageLiteral(resourceName: "raccoon-close-eyes")
          
          delay(0.1) {
            imageView.image = #imageLiteral(resourceName: "raccoon")
            
          }
        }
      }
    }
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
  
  @objc func pullToLoad() {
    _ = load().then(on: DispatchQueue.main) { photos -> Void in
      if self.photos.count > 0 && photos[0].id == self.photos[0].id {
        self.feedRefreshControl.endRefreshing()
        return
      } else {
        self.photos.append(contentsOf: photos)
        self.tableView.reloadData()
        self.feedRefreshControl.endRefreshing()
      }
    }
  }
  
  func load(with page: Int = 1) -> Promise<[Photo]> {
    feedRefreshControl.beginRefreshing()
    
    return Promise { fulfill, reject in
      if Token.getToken() != nil {
        NetworkService.getPhotosJson(with: Constants.Base.UnsplashAPI + Constants.Base.Curated,
                               parameters: [
                                "client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896",
                                "page": page
                               ],
                               headers: ["Authorization": "Bearer " + Token.getToken()!]).then { dicts -> Void in
                                guard let photos = [Photo].from(jsonArray: dicts as! [JSON]) else { return }
                                
                                fulfill(photos)
        }.catch(execute: reject)
      } else {
        NetworkService.getPhotosJson(with: Constants.Base.UnsplashAPI + Constants.Base.Curated,
                               parameters: [
                                "client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896",
                                "page": page
                               ]).then { dicts -> Void in
                                guard let photos = [Photo].from(jsonArray: dicts as! [JSON]) else { return }
                                
                                fulfill(photos)
          }.catch(execute: reject)
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
  
  @objc func toggleLikedStatus(_ notification:Notification) {
    guard let likedPhoto = notification.userInfo?["likedPressedPhoto"] as? Photo else { return }
    
    guard let row = photos.index(where: { $0.id == likedPhoto.id }) else { return }
    let indexPath = IndexPath(row: row, section: 0)
    guard let cell = tableView.cellForRow(at: indexPath) as? PhotoTableViewCell else { return }
    
    cell.isLike = likedPhoto.isLike!
    cell.heartCountLabel.text = "\(likedPhoto.heartCount!)"
  }
  
  @objc private func raccoonFound(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "ShowIAP", sender: sender)
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
        }
    }
  }
}

extension PhotosTableViewController {
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
    
    if let photoImageURL = photo.imageURL,
      let photoHeartCount = photo.heartCount,
      let photoID = photo.id,
      let photoProfileImageURL = photo.profileImageURL,
      let photoIsLike = photo.isLike {
      if let photoURL = URL(string: photoImageURL) {
        cell.photoImageView.kf.setImage(with: photoURL, options: [.transition(.fade(0.2))]) { (image, error, cacheType, imageUrl) in
          self.personalPhotos[indexPath.row] = image
        }
      }
      
      if let profileURL = URL(string: photoProfileImageURL) {
        cell.userImageView.kf.setImage(with: profileURL, options: [.transition(.fade(0.1))]) { (image, error, cacheType, imageUrl) in
          self.profileImages[indexPath.row] = image
        }
      }
      
      cell.userLabel.setTitle(photo.name, for: .normal)
      cell.isLike = photoIsLike
      cell.heartCountLabel.text = "\(photoHeartCount)"
      cell.photoID = photoID
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == photos.count - 1 {
      currentPage += 1
      
      _ = load(with: currentPage).then(on: DispatchQueue.main) { photos -> Void in
        self.photos.append(contentsOf: photos)
        self.tableView.reloadData()
        self.feedRefreshControl.endRefreshing()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.width * 0.7
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
