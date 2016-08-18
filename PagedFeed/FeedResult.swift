//
//  FeedResult.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 18/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

/**
 Result type for paged resources.
 
 With success/error results it provides convenient blocks for loading nextPage/retry operations.
 */
enum FeedResult<Page> {
    case Success(page: Page, nextPage: LoadPageBlock)
    case FeedEnd
    case Error(error: ErrorType, retry: LoadPageBlock)
    
    typealias LoadPageBlock = (completion: FeedResult<Page> -> Void) -> Void
}
