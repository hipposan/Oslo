//
//  ProfileCollectionViewCell.swift
//  Oslo
//
//  Created by hippo_san on 6/24/16.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var personalPhotoImageView: UIImageView!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.layer.shadowColor = UIColor.black.cgColor
    self.layer.shadowOpacity = 0.1
    self.layer.shadowRadius = 3.0
    self.layer.shadowOffset = CGSize(width: 2, height: 4)
  }
  
}
