//
//  PhotoTableViewCell.swift
//  Oslo
//
//  Created by hippo_san on 6/13/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

import OsloKit
import Alamofire
import PromiseKit

protocol PhotoTableViewCellDelegate: class {
  func tapToPerformSegue(_ sender: Any)
  func heartButtonDidPressed(sender: Any, isLike: Bool, heartCount: Int)
}

class PhotoTableViewCell: UITableViewCell {
  
  var isLike = false {
    didSet {
      isLike ? heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-liked"), for: .normal) : heartButton.setBackgroundImage(#imageLiteral(resourceName: "heart-outline"), for: .normal)
    }
  }
  
  var photoID: String = ""
  
  weak var delegate: PhotoTableViewCellDelegate?
  
  @IBOutlet weak var photoImageView: UIImageView! {
    didSet {
      if photoImageView.gestureRecognizers == nil {
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
      }
    }
  }
  
  @IBOutlet weak var userImageView: UIImageView! {
    didSet {
      if userImageView.gestureRecognizers == nil {
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
      }
    }
  }
  
  @IBOutlet var userLabel: UIButton!
  @IBOutlet var heartButton: UIButton!
  @IBOutlet weak var heartCountLabel: UILabel!
  
  @IBAction func heartButtonDidPressed(_ sender: Any) {
    if let token = Token.getToken() {
      let urlString = Constants.Base.UnsplashAPI + "/photos/" + photoID + "/like"
      
      if !isLike {
        isLike = !isLike
        heartCountLabel.text = "\(Int(heartCountLabel.text!)! + 1)"
        
        delegate?.heartButtonDidPressed(sender: sender, isLike: isLike, heartCount: Int(heartCountLabel.text!)!)
        
        _ = Alamofire.request(urlString, method: HTTPMethod.post, headers: ["Authorization": "Bearer " + token])
        
      } else {
        isLike = !isLike
        heartCountLabel.text = "\(Int(heartCountLabel.text!)! - 1)"
        
        delegate?.heartButtonDidPressed(sender: sender, isLike: isLike, heartCount: Int(heartCountLabel.text!)!)
        
        _ = Alamofire.request(urlString, method: HTTPMethod.delete, headers: ["Authorization": "Bearer " + token])
      }
    } else {
      delegate?.heartButtonDidPressed(sender: sender, isLike: isLike, heartCount: Int(heartCountLabel.text!)!)
    }
  }

  @IBAction func userLabelDidPressed(_ sender: Any) {
    delegate?.tapToPerformSegue(sender)
  }
  
  func tapped(_ sender: Any) {
    if let tag = (sender as AnyObject).view?.tag {
      switch tag {
      case 0:
        delegate?.tapToPerformSegue(sender)
        
      case 1:
        delegate?.tapToPerformSegue(sender)
        
      default:
        break
      }
    }
  }
  
}
