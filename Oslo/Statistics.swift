//
//  Statistics.swift
//  Oslo
//
//  Created by hippo_san on 19/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import Foundation

struct Statistics {
  let downloads: Int
  let views: Int
  let likes: Int
  
  init(downloads: Int, views: Int, likes: Int) {
    self.downloads = downloads
    self.views = views
    self.likes = likes
  }
}
