//
//  Statistics.swift
//  Oslo
//
//  Created by hippo_san on 19/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import Foundation

import Gloss

public struct Statistics: Decodable {
  public let downloads: Int?
  public let views: Int?
  public let likes: Int?
  
  public init?(json: JSON) {
    self.downloads = "downloads" <~~ json
    self.views = "views" <~~ json
    self.likes = "likes" <~~ json
  }
}
