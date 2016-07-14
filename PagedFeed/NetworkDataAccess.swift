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
    
    init(baseURL: NSURL, cacheTime: NSTimeInterval) {
        self.synchronizer = Synchronizer(baseURL: baseURL, cacheTime: cacheTime)
    }
}

extension NetworkDataAccess: DataAccess {
    
    /// Error case result in completion block (if thrown) origins from Synchronizer
    func usersWithQuery(q: String, sort: UsersResourceSort, pageSize: Int, completion: (FeedResult<[User]>) -> Void) {
        // cancel previous session
        synchronizer.cancelSession()
        
        let resource = UsersResource(q: q, sort: sort, page: nil, pageSize: nil)
        synchronizer.loadPagedResource(resource, pageSize: pageSize, completion: completion)
    }
}

// MARK: - Loading PagedResource
private extension Synchronizer {
    
    func loadPagedResource<R: PagedResource>(resource: R, pageSize: Int, completion: (FeedResult<R.ParsedObject>) -> Void) {
        loadPagedResource(resource, pageSize: pageSize, page: 0, completion: completion)
    }
    
    func loadPagedResource<R: PagedResource>(resource: R, pageSize: Int, page: Int, completion: (FeedResult<R.ParsedObject>) -> Void) {
        let resource = resource.resourceForPage(page, pageSize: pageSize)
    
        loadResource(resource) { synchronizerResult in
            let nextPage: FeedResult<R.ParsedObject>.LoadPageBlock = { [weak self] completion in
                self?.loadPagedResource(resource, pageSize: pageSize, page: page + 1, completion: completion)
            }
            let retry: FeedResult<R.ParsedObject>.LoadPageBlock = { [weak self] completion in
                self?.loadPagedResource(resource, pageSize: pageSize, page: page, completion: completion)
            }
            let endPage: FeedResult<R.ParsedObject>.LoadPageBlock = { completion in
                completion(FeedResult<R.ParsedObject>.FeedEnd)
            }
            
            switch synchronizerResult {
            case .Success(let result):
                // strangely result must be casted to R.ParsedObject to be used as _ArrayType
                switch (result as R.ParsedObject).count {
                case 0:
                    completion(.FeedEnd)
                case 1..<pageSize:
                    // if there is less results on page than page limit, then the next page is FeedEnd
                    completion(.Success(page: result, nextPage: endPage))
                default:
                    completion(.Success(page: result, nextPage: nextPage))
                }
            case .NoData:
                completion(.FeedEnd)
            case .Error(let err):
                completion(.Error(error: err, retry: retry))
            }
        }
    }
}
