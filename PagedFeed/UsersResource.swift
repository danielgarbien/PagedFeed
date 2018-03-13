//
//  UsersResource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 13/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

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
        return URLRequest(baseURL: baseURL,
                          path: "search/users",
                          parameters: parameters)!
    }
    
    var parse: (Data) throws -> [User] {
        return { data in
            return try JSONDecoder()
                .decode(GitHubSearchUsersResult.self, from: data)
                .items
        }
    }
}

private struct GitHubSearchUsersResult: Decodable {
    let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case items
    }
}

