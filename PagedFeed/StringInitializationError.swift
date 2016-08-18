//
//  StringInitializationError.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import Decodable

struct StringInitializationError: DecodingError {
    var path: [String]
    let object: AnyObject
    var rootObject: AnyObject?
    
    let type: Any.Type
    
    init(type: Any.Type, object: AnyObject) {
        self.type = type
        self.object = object
        path = []
    }
}
