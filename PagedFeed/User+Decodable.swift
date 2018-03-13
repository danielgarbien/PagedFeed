//
//  UserDecodable.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 13/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension User: Decodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        login = try container.decode(String.self, forKey: .login)
        score = try container.decode(Double.self, forKey: .score)
        type = try container.decode(UserType.self, forKey: .type)
        avatarURL = try container.decode(URL.self, forKey: .avatarURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case login, score, type
        case avatarURL = "avatar_url"
    }
}

extension UserType: Decodable {}
