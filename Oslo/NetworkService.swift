//
//  Network.swift
//  Oslo
//
//  Created by hippo_san on 17/08/2016.
//  Copyright © 2016 Ziyideas. All rights reserved.
//

import UIKit

class NetworkService {
  enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
  }
  
  class func request(url: URL, method: HTTPMethod, parameters: [[String: AnyObject]]? = nil, headers: [String: String]? = nil, completion: ((AnyObject) -> Void)? = nil) {
    let session = URLSession.shared
    
    let parsedURL = parse(url, with: parameters)
    
    var request = URLRequest(url: parsedURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    
    let task = session.dataTask(with: request) { (data, response, error) in
      guard error == nil else {
        print("An error occured: \(String(describing: error))")
        return
      }
      
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        print("Response code is not in range of 200 - 299. The code is \((response as? HTTPURLResponse)!.statusCode)")
        return
      }
      
      guard let data = data else {
        print("No data returned.")
        return 
      }
      
      do {
        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        completion?(result)
      } catch {
        print("Cannot parse data to JSON format.")
        return
      }
    }
    
    task.resume()
  }
  
  class func parse(_ url: URL, with parameters: [[String: AnyObject]]? = nil) -> URL {
    
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
  
  class func image(with imageURL: URL?, completion: @escaping (_ image: UIImage) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      if let imageURL = imageURL {
        do {
          let imageData = try Data(contentsOf: imageURL)
          guard let image = UIImage(data: imageData) else { return }
          
          DispatchQueue.main.async {
            completion(image)
          }
        } catch {
          print("Image download failed.")
        }
      }
    }
  }
}
