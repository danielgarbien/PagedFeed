//
//  User.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 13/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

struct User {

    let login: String
    let score: Double
    let type: UserType
}

enum UserType: String {
    
    case User
    case Organization
}
