//
//  NetworkDataAccess.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 31/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

class NetworkDataAccess {
    
    private let synchronizer: Synchronizer
    private let baseURL: NSURL
    
    init(baseURL: NSURL, cacheTime: NSTimeInterval) {
        self.baseURL = baseURL
        self.synchronizer = Synchronizer(cacheTime: cacheTime)
    }
}

extension NetworkDataAccess: DataAccess {
    
    /// Error case result in completion block (if thrown) origins from Synchronizer
    func usersWithQuery(q: String, sort: UsersResourceSort, pageSize: Int, completion: (FeedResult<[User]>) -> Void) {
        // cancel previous session
        synchronizer.cancelSession()
        
        let resource = UsersResource(baseURL: baseURL, q: q, sort: sort, page: nil, pageSize: nil)
        synchronizer.loadPagedResource(resource, pageSize: pageSize, completion: completion)
    }
}

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
