//
//  PhotoInfo.swift
//  Oslo
//
//  Created by hippo_san on 19/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import Foundation

public struct Exif {
  public let createTime: String
  public let width: Int
  public let height: Int
  public let make: String
  public let model: String
  public let aperture: String
  public let exposureTime: String
  public let focalLength: String
  public let iso: Int
  
  init(createTime: String,
       width: Int, height: Int,
       make: String,
       model: String,
       aperture: String,
       exposureTime: String,
       focalLength: String,
       iso: Int) {
    self.createTime = createTime
    self.width = width
    self.height = height
    self.make = make
    self.model = model
    self.aperture = aperture
    self.exposureTime = exposureTime
    self.focalLength = focalLength
    self.iso = iso
  }
}
