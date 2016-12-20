//
//  NetworkDataAccess.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 31/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

class NetworkDataAccess {
    
    fileprivate let synchronizer: Synchronizer
    fileprivate let baseURL: URL
    
    init(baseURL: URL, cacheTime: TimeInterval) {
        self.baseURL = baseURL
        self.synchronizer = Synchronizer(cacheTime: cacheTime)
    }
}

extension NetworkDataAccess: DataAccess {
    
    /// Error case result in completion block (if thrown) origins from Synchronizer
    func usersWithQuery(_ q: String, sort: UsersResourceSort, pageSize: Int, completion: (FeedResult<[User]>) -> Void) {
        // cancel previous session
        synchronizer.cancelSession()
        
        let resource = UsersResource(baseURL: baseURL, q: q, sort: sort, page: nil, pageSize: nil)
        synchronizer.loadPagedResource(resource, pageSize: pageSize, completion: completion)
    }
}

extension UsersResource: PagedResource {
    
    typealias ParsedObject = [User]
    
    func resourceForPage(_ page: Int, pageSize: Int) -> UsersResource {
        return UsersResource(
            baseURL: baseURL,
            q: q,
            sort: sort,
            page: page,
            pageSize: pageSize)
    }
}
