//
//  DataAccess.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 29/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

protocol DataAccess {
    
    func usersWithQuery(q: String, sort: UsersResourceSort, pageSize: Int, completion: (FeedResult<[User]>) -> Void)
}
