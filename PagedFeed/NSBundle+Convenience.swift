//
//  NSBundle+Convenience.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 29/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension NSBundle {
    
    func apiBaseUrl() -> String {
        return infoValueForKey("MY_API_BASE_URL_ENDPOINT")!
    }
    
    func infoValueForKey<Value>(key: String) -> Value? {
        return infoDictionary![key] as? Value
    }
}
