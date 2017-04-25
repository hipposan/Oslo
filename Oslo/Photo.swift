//
//  Photo.swift
//  Oslo
//
//  Created by hippo_san on 02/09/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//
import Gloss

public struct Photo: Decodable {
  public let id: String?
  public let imageURL: String?
  public let profileImageURL: String?
  public let name: String?
  public let userName: String?
  public var isLike: Bool?
  public var heartCount: Int?
  public let bio: String?
  public let location: String?
  public let portfolioURL: String?
  
  public init?(json: JSON) {
    self.id = "id" <~~ json
    
    guard let photoURLs: JSON = "urls" <~~ json else { return nil }
    self.imageURL = "regular" <~~ photoURLs
    
    guard let user: JSON = "user" <~~ json,
      let profileImage: JSON = "profile_image" <~~ user else { return nil }
    self.profileImageURL = "medium" <~~ profileImage
    
    self.name = "name" <~~ json
    self.userName = "username" <~~ json
    self.isLike = "liked_by_user" <~~ json
    self.heartCount = "likes" <~~ json
    self.bio = "bio" <~~ json
    self.location = "location" <~~ json
    self.portfolioURL = "portfolio_url" <~~ json
  }
}
