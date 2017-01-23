//
//  PublishedPhotoCollectionViewCell.swift
//  Oslo
//
//  Created by Ziyi Zhang on 01/12/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class PublishedPhotoCollectionViewCell: UICollectionViewCell {
  @IBOutlet var publishedPhotoImageView: UIImageView!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.1
    self.layer.shadowRadius = 3.0
    self.layer.shadowOffset = CGSize(width: 2, height: 4)
  }
}
