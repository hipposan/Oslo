//
//  Photo.swift
//  Oslo
//
//  Created by hippo_san on 02/09/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

public struct Photo {
  public let id: String
  public let imageURL: String
  public let profileImageURL: String
  public let name: String
  public let userName: String
  public var isLike: Bool
  public var heartCount: Int
  public let bio: String
  public let location: String
  public let portfolioURL: String
  
  init(id: String,
       imageURL: String,
       profileImageURL: String,
       name: String,
       userName: String,
       isLike: Bool,
       heartCount: Int,
       bio: String,
       location: String,
       portfolioURL: String) {
    self.id = id
    self.imageURL = imageURL
    self.profileImageURL = profileImageURL
    self.name = name
    self.userName = userName
    self.isLike = isLike
    self.heartCount = heartCount
    self.bio = bio
    self.location = location
    self.portfolioURL = portfolioURL
  }
}
