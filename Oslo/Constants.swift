//
//  Constants.swift
//  Oslo
//
//  Created by hippo_san on 17/08/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

struct Constants {
  
  struct Base {
    static let UnsplashURL = "https://unsplash.com"
    static let UnsplashAPI = "https://api.unsplash.com"
    static let Curated = "/photos/curated"
    static let Authorize = "/oauth/authorize"
    static let Token = "/oauth/token"
    static let Me = "/me"
  }
  
  struct Parameters {
    static let ClientID = ["client_id": "a1a50a27313d9bba143953469e415c24fc1096aea3be010bd46d4bd252a60896"]
    static let ClientSecret = ["client_secret": "c81b39a6a1f921a0b2b29de29f44fd176ffc101e816c5d2d34b6c951a885a68b"]
    static let RedirectURI = ["redirect_uri": "Oslo://photos"]
    static let GrantType = ["grant_type": "authorization_code"]
    static let ResponseType = ["response_type": "code"]
    static let Scope = ["scope": "public+read_user+write_likes"]
  }
}
