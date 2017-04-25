//
//  Network.swift
//  Oslo
//
//  Created by hippo_san on 17/08/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import PromiseKit
import Alamofire

public class NetworkService {
  public static func getPhotosJson(with url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, headers: [String: String]? = nil) -> Promise<[NSDictionary]> {
    return Promise { fulfill, reject in
      Alamofire.request(url, parameters: parameters, headers: headers).responseJSON() { response in
        switch response.result {
        case .success(let dict):
          fulfill(dict as! [NSDictionary])
        case .failure(let error):
          reject(error)
        }
      }
    }
  }
  
  public static func getJson(with url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, headers: [String: String]? = nil) -> Promise<Dictionary<String, AnyObject>> {
    return Promise { fulfill, reject in
      Alamofire.request(url, parameters: parameters, headers: headers).responseJSON() { response in
        switch response.result {
        case .success(let dict):
          fulfill(dict as! Dictionary<String, AnyObject>)
        case .failure(let error):
          reject(error)
        }
      }
    }
  }
  
  public class func parse(_ url: URL, with parameters: [[String: AnyObject]]? = nil) -> URL {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    components.queryItems = [URLQueryItem]()
    
    if let params = parameters {
      for param in params {
        for (key, value) in param {
          let queryItem = URLQueryItem(name: key, value: "\(value)")
          components.queryItems!.append(queryItem)
        }
      }
    }
    
    return components.url!
  }
}
