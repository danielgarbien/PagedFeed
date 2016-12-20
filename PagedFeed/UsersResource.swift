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
    let baseURL: URL
    let q: String
    let sort: UsersResourceSort
    let page: Int?
    let pageSize: Int?
}

enum UsersResourceSort {
    case bestMatch
    case byFollowers
    
    fileprivate var param: AnyObject? {
        switch self {
        case .bestMatch: return nil
        case .byFollowers: return "followers" as AnyObject?
        }
    }
}

private extension UsersResource {
    
    var parameters: [String: AnyObject] {
        var param = [String: AnyObject]()
        param["q"] = q as AnyObject?
        param["sort"] = sort.param
        param["page"] = page as AnyObject?
        param["per_page"] = pageSize as AnyObject?
        return param
    }
}

extension UsersResource: Resource {

    func request() -> URLRequest {
        return URLRequest(url: baseURL,
                            cachePolicy: "search/users",
                            timeoutInterval: parameters)!
    }
    
    var parse: (Data) throws -> [User] {
        return { data in
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return try json => "items"
        }
    }
}

