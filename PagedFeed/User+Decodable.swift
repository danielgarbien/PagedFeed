//
//  UserDecodable.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 13/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import Decodable

extension User: Decodable {
    
    static func decode(_ j: AnyObject) throws -> User {
        return try User(
            login: j => "login",
            score: j => "score",
            type: j => "type",
            avatarURL: j => "avatar_url"
        )
    }
}

extension UserType: Decodable {}
