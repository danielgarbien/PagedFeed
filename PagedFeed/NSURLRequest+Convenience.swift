//
//  NSURLRequest+Convenience.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension NSURLRequest {
    
    convenience init?(baseURL: NSURL, path: String?, parameters: [String: AnyObject]?) {
        let URL = baseURL.URLByAppendingPathComponent(path ?? "")
        let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false)
        
        components?.queryItems = parameters?.map { key, value -> NSURLQueryItem in
            NSURLQueryItem(name: String(key), value: String(value))
        }
        
        guard let componentsURL = components?.URL else {
            return nil
        }
        self.init(URL: componentsURL)
    }
}