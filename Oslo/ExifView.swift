//
//  ExifView.swift
//  Oslo
//
//  Created by hippo_san on 19/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class ExifView: UIView {
  @IBOutlet var createdTimeTitleLabel: UILabel! {
    didSet {
      createdTimeTitleLabel.text = localize(with: "Published")
    }
  }
  @IBOutlet weak var createdTimeLabel: UILabel!
  @IBOutlet var dimensionTitleLabel: UILabel! {
    didSet {
      dimensionTitleLabel.text = localize(with: "Dimensions")
    }
  }
  @IBOutlet weak var dimensionsLabel: UILabel!
  @IBOutlet var makeTitleLabel: UILabel! {
    didSet {
      makeTitleLabel.text = localize(with: "Camera Make")
    }
  }
  @IBOutlet weak var makeLabel: UILabel!
  @IBOutlet var modelTitleLabel: UILabel! {
    didSet {
      modelTitleLabel.text = localize(with: "Camera Model")
    }
  }
  @IBOutlet weak var modelLabel: UILabel!
  @IBOutlet var apertureTitleLabel: UILabel! {
    didSet {
      apertureTitleLabel.text = localize(with: "Aperture")
    }
  }
  @IBOutlet weak var apertureLabel: UILabel!
  @IBOutlet var exposureTitleLabel: UILabel! {
    didSet {
      exposureTitleLabel.text = localize(with: "Exposure Time")
    }
  }
  @IBOutlet weak var exposureTimeLabel: UILabel!
  @IBOutlet var focalTitleLabel: UILabel! {
    didSet {
      focalTitleLabel.text = localize(with: "Focal Length")
    }
  }
  @IBOutlet weak var focalLengthLabel: UILabel!
  @IBOutlet var isoTitleLabel: UILabel! {
    didSet {
      isoTitleLabel.text = localize(with: "ISO")
    }
  }
  @IBOutlet weak var isoLabel: UILabel!
}
