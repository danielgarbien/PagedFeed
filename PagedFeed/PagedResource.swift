//
//  PagedResource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 03/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol PagedResource: Resource {
    
    // PagedResource must return array of objects
    associatedtype ParsedObject: _ArrayProtocol
    
    func resourceForPage(_ page: Int, pageSize: Int) -> Self
}
