//
//  Constants.swift
//  Oslo
//
//  Created by hippo_san on 17/08/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

public struct Constants {
  
  public struct Base {
    public static let UnsplashURL = "https://unsplash.com"
    public static let UnsplashAPI = "https://api.unsplash.com"
    public static let Curated = "/photos/curated"
    public static let Authorize = "/oauth/authorize"
    public static let Token = "/oauth/token"
    public static let Me = "/me"
    public static let Random = "/photos/random"
  }
  
  public struct Parameters {
    public static let ClientID = ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]
    public static let ClientSecret = ["client_secret": "c81b39a6a1f921a0b2b29de29f44fd176ffc101e816c5d2d34b6c951a885a68b"]
    public static let RedirectURI = ["redirect_uri": "Oslo://photos"]
    public static let GrantType = ["grant_type": "authorization_code"]
    public static let ResponseType = ["response_type": "code"]
    public static let Scope = ["scope": "public+read_user+write_likes"]
  }
  
  public struct NotificationName {
    public static let likeSendNotification = NSNotification.Name(rawValue: "likedSent")
    public static let likeGetNotification = NSNotification.Name(rawValue: "likedGet")
  }
}

public enum Meals {
  case hamburgerAndChips, ChikenAndCoke, LollipopAndCoffee
}

extension Meals: CustomStringConvertible {
  public var description: String {
    switch self {
    case .hamburgerAndChips: return "My favorite! You a good people!"
    case .ChikenAndCoke: return "Delicious! I gain weight"
    case .LollipopAndCoffee: return "I don't drink coffee. But this good"
    }
  }
}

public enum FedStatus {
  case fed, noFed
}

extension FedStatus: CustomStringConvertible {
  public var description: String {
    switch self {
    case .fed: return "As gift, see app's icon your home screen"
    case .noFed: return "Maybe I find someone else"
    }
  }
}
