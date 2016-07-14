//
//  UsersResource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 13/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import Decodable

struct UsersResource {
    let q: String
    let sort: UsersResourceSort
    let page: Int?
    let pageSize: Int?
}

enum UsersResourceSort {
    case BestMatch
    case ByFollowers
    
    private var param: AnyObject? {
        switch self {
        case .BestMatch: return nil
        case .ByFollowers: return "followers"
        }
    }
}

extension UsersResource: Resource {
    
    var path: String? {
        return "search/users"
    }
    
    var parameters: [String: AnyObject] {
        var param = [String: AnyObject]()
        param["q"] = q
        param["sort"] = sort.param
        param["page"] = page
        param["per_page"] = pageSize
        return param
    }
    
    var parse: (NSData) throws -> [User] {
        return { data in
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            return try json => "items"
        }
    }
}

