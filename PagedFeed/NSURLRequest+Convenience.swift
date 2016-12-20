//
//  NSURLRequest+Convenience.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension URLRequest {
    
    init?(baseURL: URL, path: String?, parameters: [String: AnyObject]?) {
        let URL = baseURL.appendingPathComponent(path ?? "")
        var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)
        
        components?.queryItems = parameters?.map { key, value -> URLQueryItem in
            URLQueryItem(name: String(key), value: String(describing: value))
        }
        
        guard let componentsURL = components?.url else {
            return nil
        }
        self.init(url: componentsURL)
    }
}
