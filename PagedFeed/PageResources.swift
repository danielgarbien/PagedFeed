//
//  PageResources.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 03/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol PageResources where PageResource: Resource {
    
    associatedtype PageResource
    
    func resourceForPage(_ page: Int, pageSize: Int) -> PageResource
    
    func isLastPage(_ page: PageResource.ParsedObject, pageSize: Int) -> Bool
}
