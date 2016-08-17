//
//  UsersPagedResource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 13/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension UsersResource: PagedResource {
    
    typealias ParsedObject = [User]
    
    func resourceForPage(page: Int, pageSize: Int) -> UsersResource {
        return UsersResource(
            baseURL: baseURL,
            q: q,
            sort: sort,
            page: page,
            pageSize: pageSize)
    }
}
