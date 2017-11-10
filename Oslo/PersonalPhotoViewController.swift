//
//  PersonalPhotoViewController.swift
//  Oslo
//
//  Created by hippo_san on 29/07/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit
import Social

import OsloKit
import Alamofire
import PromiseKit

class PersonalPhotoViewController: UIViewController {
  
  var photo: Photo!
  var personalPhoto: UIImage?
  
  fileprivate var exifInfo: Exif!
  fileprivate var statisticsInfo: Statistics!
  
  private let emoji: Array = ["🗾", "🎑", "🏞", "🌅", "🌄", "🌠", "🎇", "🎆", "🌇", "🌆", "🏙", "🌃", "🌌", "🌉", "🌁"]
  
  var exifView: ExifView?
  var statisticsView: StatisticsView?
  
  @IBOutlet var personalPhotoImageView: UIImageView!
  @IBOutlet var heartButton: UIButton!
  @IBOutlet var heartCountLabel: UILabel!
  @IBOutlet var downloadButton: UIButton!
  @IBOutlet var shareButton: UIButton!
  @IBOutlet var statisticsButton: UIButton!
  @IBOutlet var exifButton: UIButton!
  @IBOutlet var savePhotoLabel: UILabel!
  
  @IBAction func closeButtonPressed(_ sender: Any) {
    dismiss(animated: true)
  }
  
  @IBAction func heartButtonDidPressed(_ sender: Any) {
    if let token = Token.getToken() {
      guard let photoIsLiked = photo.isLike,
        let photoID = photo.id else { return }
      
      if !photoIsLiked {
        heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal)
        heartCountLabel.text = "\(Int(heartCountLabel.text!)! + 1)"
        
        photo.isLike = !photoIsLiked
        photo.heartCount = Int(heartCountLabel.text!)!
        
        
        
        _ = Alamofire.request(Constants.Base.UnsplashAPI + "/photos/" + photoID + "/like",
                          method: HTTPMethod.post,
                          headers: ["Authorization": "Bearer " + token])
      } else {
        heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
        heartCountLabel.text = "\(Int(heartCountLabel.text!)! - 1)"
        
        photo.isLike = !photoIsLiked
        photo.heartCount = Int(heartCountLabel.text!)!
        
        _ = Alamofire.request(Constants.Base.UnsplashAPI + "/photos/" + photoID + "/like",
                              method: HTTPMethod.delete,
                              headers: ["Authorization": "Bearer " + token])
      }
      
      NotificationCenter.default.post(name: Constants.NotificationName.likeSendNotification, object: nil, userInfo: ["likedPressedPhoto": photo])
    } else {
      let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
      present(loginViewController, animated: true)
    }
  }
  
  @IBAction func downloadButtonDidPressed(_ sender: Any) {
    guard personalPhoto != nil else { return }
    UIImageWriteToSavedPhotosAlbum(personalPhoto!, self, #selector(save(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  
  @IBAction func shareButtonDIdPressed(_ sender: Any) {
    let shareImage: UIImage = personalPhotoImageView.image!
    let activityItems = [shareImage] as [Any]
    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      activityViewController.popoverPresentationController?.sourceView = self.view
    }
    
    self.present(activityViewController, animated: true)
  }
  
  @IBAction func statisticsButtonDidPressed(_ sender: Any) {
    if statisticsView == nil {
      if exifView != nil {
        exifButton.setBackgroundImage(#imageLiteral(resourceName: "camera"), for: .normal)
        
        exifView?.removeFromSuperview()
        exifView = nil
      }
      
      statisticsButton.setBackgroundImage(#imageLiteral(resourceName: "statistics-on"), for: .normal)
      
      if let view = UIView.load(from: "StatisticsView", with: personalPhotoImageView.bounds)  as? StatisticsView {
        statisticsView = view
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let statisticsDownloads = statisticsInfo.downloads,
          let statisticsViews = statisticsInfo.views,
          let statisticsLikes = statisticsInfo.likes else { return }
        
        statisticsView!.downloadsLabel.text = numberFormatter.string(from: statisticsDownloads as NSNumber)
        statisticsView!.viewsLabel.text = numberFormatter.string(from: statisticsViews as NSNumber)
        statisticsView!.likesLabel.text = numberFormatter.string(from: statisticsLikes as NSNumber)
        
        personalPhotoImageView.addSubview(statisticsView!)
      }
    } else {
      statisticsButton.setBackgroundImage(#imageLiteral(resourceName: "statistics"), for: .normal)
      
      statisticsView?.removeFromSuperview()
      statisticsView = nil
    }
  }
  
  @IBAction func exifButtonDidPressed(_ sender: Any) {
    if exifView == nil {
      if statisticsView != nil {
        statisticsButton.setBackgroundImage(#imageLiteral(resourceName: "statistics"), for: .normal)
        
        statisticsView?.removeFromSuperview()
        statisticsView = nil
      }
      
      exifButton.setBackgroundImage(#imageLiteral(resourceName: "camera-on"), for: .normal)
      
      if let view = UIView.load(from: "ExifView", with: personalPhotoImageView.bounds) as? ExifView {
        exifView = view
        
        guard let createTime = exifInfo.createTime,
          let width = exifInfo.width,
          let height = exifInfo.height,
          let make = exifInfo.make,
          let model = exifInfo.model,
          let aperture = exifInfo.aperture,
          let exposure = exifInfo.exposureTime,
          let focalLength = exifInfo.focalLength,
          let iso = exifInfo.iso else { return }
        
        let dateTime = createTime.components(separatedBy: "T")[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateTime)
        dateFormatter.dateStyle = .long
        let createDate = dateFormatter.string(from: date!)
        exifView!.createdTimeLabel.text = createDate
        exifView!.dimensionsLabel.text = "\(width) x \(height)"
        exifView!.makeLabel.text = make
        exifView!.modelLabel.text = model
        exifView!.apertureLabel.text = aperture
        exifView!.exposureTimeLabel.text = exposure
        exifView!.focalLengthLabel.text = focalLength
        exifView!.isoLabel.text = "\(iso)"
        
        personalPhotoImageView.addSubview(exifView!)
      }
    } else {
      exifButton.setBackgroundImage(#imageLiteral(resourceName: "camera"), for: .normal)
      
      exifView?.removeFromSuperview()
      exifView = nil
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let photoIsLike = photo.isLike,
      let photoImageURL = photo.imageURL,
      let photoHeartCount = photo.heartCount else { return }
    
    if let downloadedImage = personalPhoto {
      personalPhotoImageView.image = downloadedImage
    } else {
      personalPhotoImageView.image = nil
      
      let imageURL = URL(string: photoImageURL)
      personalPhotoImageView.kf.setImage(with: imageURL, options: [.transition(.fade(0.1))]) { (image, error, cacheType, imageUrl) in
        self.personalPhoto = image
      }
    }
    
    photoIsLike ? heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal) : heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
    
    heartCountLabel.text = String(photoHeartCount)
    
    savePhotoLabel.alpha = 0
    
    load()
  }
  
  private func load() {
    guard let photoID = photo.id else { return }
    
    let statisticsURLString = Constants.Base.UnsplashAPI + "/photos/" + photoID + "/stats"
    
    _ = NetworkService.getJson(with: statisticsURLString,
                           parameters: ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]).then { dict -> Void in
                            guard let statisticsInfoData = Statistics(json: dict) else { return }
                            self.statisticsInfo = statisticsInfoData
    }
    
    let exifURLString = Constants.Base.UnsplashAPI + "/photos/" + photoID
    
    _ = NetworkService.getJson(with: exifURLString,
                               parameters: ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]).then { dict -> Void in
                                guard let exifInfoData = Exif(json: dict) else { return }
                                self.exifInfo = exifInfoData
    }
  }
  
  @objc private func save(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      savePhotoLabel.text = localize(with: "Save photo failed")
      print(error.localizedDescription)
    } else {
      savePhotoLabel.text = "\(emoji.randomItem())" + localize(with: "Photo saved")
      savePhotoLabel.transform = CGAffineTransform(translationX: -20, y: -20)
      
      UIView.animate(withDuration: 1, animations: {
        self.savePhotoLabel.alpha = 1
        self.savePhotoLabel.transform = CGAffineTransform.identity
      }, completion: { _ in
        delay(1) {
          UIView.animate(withDuration: 1, animations: {
            self.savePhotoLabel.alpha = 0
            self.savePhotoLabel.transform = CGAffineTransform(translationX: 20, y: 20)
          })
        }
      })
    }
  }
}
