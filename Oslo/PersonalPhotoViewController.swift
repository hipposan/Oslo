//
//  PersonalPhotoViewController.swift
//  Oslo
//
//  Created by hippo_san on 29/07/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit
import Social

protocol PersonalPhotoViewControllerDelegate: class {
  func heartButtonDidPressed(with photoID: String, isLike: Bool, heartCount: Int)
}

class PersonalPhotoViewController: UIViewController {
  
  var photo: Photo!
  var personalPhoto: UIImage?
  
  fileprivate var exifInfo: Exif?
  fileprivate var statisticsInfo: Statistics?
  
  private let emoji: Array = ["🗾", "🎑", "🏞", "🌅", "🌄", "🌠", "🎇", "🎆", "🌇", "🌆", "🏙", "🌃", "🌌", "🌉", "🌁"]
  
  var exifView: ExifView?
  var statisticsView: StatisticsView?
  
  weak var delegate: PersonalPhotoViewControllerDelegate?
  
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
      let url = URL(string: Constants.Base.UnsplashAPI + "/photos/" + photo.id + "/like")!
      
      if !photo.isLike {
        heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal)
        heartCountLabel.text = "\(Int(heartCountLabel.text!)! + 1)"
        
        photo.isLike = !photo.isLike
        photo.heartCount = Int(heartCountLabel.text!)!
        
        delegate?.heartButtonDidPressed(with: photo.id, isLike: photo.isLike, heartCount: photo.heartCount)
        
        NetworkService.request(url: url, method: NetworkService.HTTPMethod.POST, headers: ["Authorization": "Bearer " + token])
      } else {
        heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
        heartCountLabel.text = "\(Int(heartCountLabel.text!)! - 1)"
        
        photo.isLike = !photo.isLike
        photo.heartCount = Int(heartCountLabel.text!)!
        
        delegate?.heartButtonDidPressed(with: photo.id, isLike: photo.isLike, heartCount: photo.heartCount)
        
        NetworkService.request(url: url, method: NetworkService.HTTPMethod.DELETE, headers: ["Authorization": "Bearer " + token])
      }
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
        
        guard statisticsInfo != nil else { return }
        
        statisticsView!.downloadsLabel.text = numberFormatter.string(from: statisticsInfo!.downloads as NSNumber)
        statisticsView!.viewsLabel.text = numberFormatter.string(from: statisticsInfo!.views as NSNumber)
        statisticsView!.likesLabel.text = numberFormatter.string(from: statisticsInfo!.likes as NSNumber)
        
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
        
        guard exifInfo != nil else { return }
        
        let dateTime = exifInfo!.createTime.components(separatedBy: "T")[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateTime)
        dateFormatter.dateStyle = .long
        let createDate = dateFormatter.string(from: date!)
        exifView!.createdTimeLabel.text = createDate
        
        exifView!.dimensionsLabel.text = "\(exifInfo!.width) x \(exifInfo!.height)"
        exifView!.makeLabel.text = exifInfo!.make
        exifView!.modelLabel.text = exifInfo!.model
        exifView!.apertureLabel.text = exifInfo!.aperture
        exifView!.exposureTimeLabel.text = exifInfo!.exposureTime
        exifView!.focalLengthLabel.text = exifInfo!.focalLength
        exifView!.isoLabel.text = "\(exifInfo!.iso)"
        
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
    
    if let downloadedImage = personalPhoto {
      personalPhotoImageView.image = downloadedImage
    } else {
      personalPhotoImageView.image = nil
      
      let imageURL = URL(string: photo.imageURL)
      NetworkService.image(with: imageURL) { image in
        self.personalPhoto = image
        self.personalPhotoImageView.image = image
      }
    }
    
    photo.isLike ? heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal) : heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
    
    heartCountLabel.text = String(photo.heartCount)
    
    savePhotoLabel.alpha = 0
    
    load()
  }
  
  private func load() {
    
      let statisticsURL = URL(string: Constants.Base.UnsplashAPI + "/photos/" + photo.id + "/stats")!
      
      NetworkService.request(url: statisticsURL, method: NetworkService.HTTPMethod.GET,
                             parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>]) { jsonData in
                              OperationService.parseJsonWithStatisticsData(jsonData as! Dictionary<String, AnyObject>) { statisticsInfo in
                                self.statisticsInfo = statisticsInfo
                              }
    }
    
      let exifURL = URL(string: Constants.Base.UnsplashAPI + "/photos/" + photo.id)!
      
      NetworkService.request(url: exifURL, method: NetworkService.HTTPMethod.GET,
                             parameters: [Constants.Parameters.ClientID as Dictionary<String, AnyObject>]) { jsonData in
                              OperationService.parseJsonWithExifData(jsonData as! Dictionary<String, AnyObject>) { exifInfo in
                                self.exifInfo = exifInfo
                              }
      
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
