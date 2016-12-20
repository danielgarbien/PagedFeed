//
//  NSURL+Decodable.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import Decodable

extension URL: Decodable {
    
    public static func decode(_ j: AnyObject) throws -> URL {
        guard let URL = self.init(string: try String.decode(j)) else {
            throw StringInitializationError(type: type(of: j), object: j)
        }
        return URL
    }
}
