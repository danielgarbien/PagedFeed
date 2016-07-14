//
//  DaoTests.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 29/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import XCTest
@testable import PagedFeed

// CAUTION: Tests may fall because of service rate limit or bad network condition

class DaoTests: XCTestCase {

    let dao: DataAccess = NetworkDataAccess(
        baseURL: NSURL(string: NSBundle.mainBundle().apiBaseUrl())!,
        cacheTime: 60
    )
    
    func testSingleQuery() {
        
        let expectation = expectationWithDescription("all items retrieved")
        
        dao.usersWithQuery("d", sort: .BestMatch, pageSize: 10) { (feedResult) in
            if case .Success = feedResult {
                expectation.fulfill()
            } else {
                XCTFail()
            }
        }

        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testQuietCancelation() {
        
        dao.usersWithQuery("d", sort: .BestMatch, pageSize: 50) { (feedResult) in
            if case .Error(let message) = feedResult {
                print(message)
                XCTFail("Cancellation should fail quietly")
            }
        }

        testSingleQuery()
    }
    
    func testCachePerformance() {
        
        func loadSingleQuery() {
            let expectation = expectationWithDescription("random request loaded")
            dao.usersWithQuery("daniel", sort: .BestMatch, pageSize: 10) {result in
                if case .Success = result {
                    expectation.fulfill()
                }
            }
            waitForExpectationsWithTimeout(60, handler: nil)
        }
        
        // first time run of a query should actualy connect with API
        loadSingleQuery()

        // second run should return with results from cache
        measureBlock {
            loadSingleQuery()
        }
    }
}
