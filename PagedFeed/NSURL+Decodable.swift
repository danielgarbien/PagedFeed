//
//  NSURL+Decodable.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import Decodable

extension NSURL: Decodable {
    
    public static func decode(j: AnyObject) throws -> Self {
        guard let URL = self.init(string: try String.decode(j)) else {
            throw StringInitializationError(type: j.dynamicType, object: j)
        }
        return URL
    }
}
