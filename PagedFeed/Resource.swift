//
//  Resource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 02/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol Resource {
    func request() -> NSURLRequest
    
    associatedtype ParsedObject
    var parse: (NSData) throws -> ParsedObject { get }
}
