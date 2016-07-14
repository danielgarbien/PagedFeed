//
//  Resource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 02/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol Resource {
    var path: String? { get }
    var parameters: [String: AnyObject] { get }
    
    associatedtype ParsedObject
    var parse: (NSData) throws -> ParsedObject { get }
}

extension Resource {
    
    func requestWithBaseURL(baseURL: NSURL) -> NSURLRequest {
        let URL = baseURL.URLByAppendingPathComponent(path ?? "")
        let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false)!
        
        components.queryItems = parameters.map { key, value -> NSURLQueryItem in
            NSURLQueryItem(name: String(key), value: String(value))
        }
        
        return NSURLRequest(URL: components.URL!)
    }
}
