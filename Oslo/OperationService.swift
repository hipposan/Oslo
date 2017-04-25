//
//  Operation.swift
//  Oslo
//
//  Created by Ziyi Zhang on 18/11/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import Foundation

public class OperationService {
  public class func parseJsonWithPhotoData(_ data: NSDictionary, completion: (_ photo: Photo) -> Void) {
    var id: String = ""
    var imageURL: String = ""
    var profileImageURL: String = ""
    var name: String = ""
    var userName: String = ""
    var isLike: Bool = false
    var heartCount: Int = 0
    var bio: String = ""
    var location: String = ""
    var portfolioURL: String = ""
    
    if let photoID = data["id"] as? String {
      id = photoID
    }
    
    if let photoURLs = data["urls"] as? [String: AnyObject],
      let photoURL = photoURLs["regular"] as? String {
      imageURL = photoURL
    }
    
    if let user = data["user"] as? [String: AnyObject] {
      if let profileImage = user["profile_image"] as? [String: AnyObject],
        let mediumImage = profileImage["medium"] as? String {
        profileImageURL = mediumImage
      }
      
      if let fullName = user["name"] as? String {
        name = fullName
      }
      
      if let webName = user["username"] as? String {
        userName = webName
      }
      
      if let bioDescription = user["bio"] as? String {
        bio = bioDescription
      }
      
      if let locationDescription = user["location"] as? String {
        location = locationDescription
      }
      
      if let portfolioURLDescription = user["portfolio_url"] as? String {
        portfolioURL = portfolioURLDescription
      }
    }
    
    if let likeOrNot = data["liked_by_user"] as? Bool {
      isLike = likeOrNot
    }
    
    if let likes = data["likes"] as? Int {
      heartCount = likes
    }
    
    let photo = Photo(id: id,
                      imageURL: imageURL,
                      profileImageURL: profileImageURL,
                      name: name, userName: userName,
                      isLike: isLike,
                      heartCount: heartCount,
                      bio: bio,
                      location: location,
                      portfolioURL: portfolioURL)
    completion(photo)
    
  }
  
  public class func parseJsonWithExifData(_ data: Dictionary<String, AnyObject>, completion: (_ exifData: Exif) -> Void) {
      var createTime: String = ""
      var width: Int = 0
      var height: Int = 0
      var make: String = ""
      var model: String = ""
      var aperture: String = ""
      var exposureTime: String = ""
      var focalLength: String = ""
      var iso: Int = 0
      
      if let photoCreatedTime = data["created_at"] as? String {
        createTime = photoCreatedTime
      }
      
      if let photoWidth = data["width"] as? Int {
        width = photoWidth
      }
      
      if let photoHeight = data["height"] as? Int {
        height = photoHeight
      }
      
      if let photoExif = data["exif"] as? [String: AnyObject] {
        if let photoMake = photoExif["make"] as? String {
          make = photoMake
        }
        
        if let photoModel = photoExif["model"] as? String {
          model = photoModel
        }
        
        if let photoAperture = photoExif["aperture"] as? String {
          aperture = photoAperture
        }
        
        if let photoExposureTime = photoExif["exposure_time"] as? String {
          exposureTime = photoExposureTime
        }
        
        if let photoFocalLength = photoExif["focal_length"] as? String {
          focalLength = photoFocalLength
        }
        
        if let photoISO = photoExif["iso"] as? Int {
          iso = photoISO
        }
      }
      
      let exifInfo = Exif(createTime: createTime,
                          width: width,
                          height: height,
                          make: make,
                          model: model,
                          aperture: aperture,
                          exposureTime: exposureTime,
                          focalLength: focalLength,
                          iso: iso)
      completion(exifInfo)
  }
  
  public class func parseJsonWithStatisticsData(_ data: Dictionary<String, AnyObject>, completion: (_ statisticsData: Statistics) -> Void) {
      var downloads: Int = 0
      var views: Int = 0
      var likes: Int = 0
      
      if let downloadsNumber = data["downloads"] as? Int {
        downloads = downloadsNumber
      }
      
      if let viewsNumber = data["views"] as? Int {
        views = viewsNumber
      }
      
      if let likesNumber = data["likes"] as? Int {
        likes = likesNumber
      }
      
      let statisticsInfo = Statistics(downloads: downloads, views: views, likes: likes)
      completion(statisticsInfo)
  }
}

public struct Token {
  public static let userDefaults = UserDefaults.standard
  
  public static func getToken() -> String? {
    return userDefaults.string(forKey: "token")
  }
  
  public static func saveToken(_ token: String) {
    userDefaults.set(token, forKey: "token")
  }
  
  public static func removeToken() {
    userDefaults.removeObject(forKey: "token")
  }
}
