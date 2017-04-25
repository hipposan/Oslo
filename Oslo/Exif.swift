//
//  PhotoInfo.swift
//  Oslo
//
//  Created by hippo_san on 19/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import Foundation

import Gloss

public struct Exif: Decodable {
  public let createTime: String?
  public let width: Int?
  public let height: Int?
  public let make: String?
  public let model: String?
  public let aperture: String?
  public let exposureTime: String?
  public let focalLength: String?
  public let iso: Int?
  
  public init?(json: JSON) {
    self.createTime = "created_at" <~~ json
    self.width = "width" <~~ json
    self.height = "height" <~~ json
    
    guard let photoExif: JSON = "exif" <~~ json else { return nil }
    self.make = "make" <~~ photoExif
    
    self.model = "model" <~~ photoExif
    self.aperture = "aperture" <~~ photoExif
    self.exposureTime = "exposure_time" <~~ photoExif
    self.focalLength = "focal_length" <~~ photoExif
    self.iso = "iso" <~~ photoExif
  }
}
