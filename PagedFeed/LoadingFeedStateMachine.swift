//
//  LoadingFeedStateMachine.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 09/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import UIKit

enum LoadingFeedState<Page> {
    case Idle
    case Loading(initial: Bool)
    case Succeed(page: Page)
    case Failed(error: ErrorType)
    case Ended
}


/**
 Convenience state machine to be used with data access methods returning FeedResult in completion block.
 
 1) Idle is the initial state, after first state change the state machine cannot get back to Idle
 2) Call startFeed(:_) to start feed - it changes state to Loading(initial: true). startFeed(:_) might be called afterwards as well to start a new feed.
 3) Loading may change to either Succeed, Failed or Ended state.
 4) Call next() when in Succeed or Failed to respectively load next page or the page that failed to be loaded - changes state to Loading(initial: false). 
    If next() is called in a state different than Succeed/Failed then it has no effect.
 4) Ended state means feed edned.
 
 Track state changes with stateDidChange block.
 */
class LoadingFeedStateMachine<Page> {
    
    private(set) var state: LoadingFeedState<Page> = .Idle {
        didSet { stateDidChange(state) }
    }
    
    init(stateDidChange: LoadingFeedState<Page> -> Void) {
        self.stateDidChange = stateDidChange
    }
    
    func startFeed(@noescape load: FeedResult<Page>.LoadPageBlock) {
        state = .Loading(initial: true)
        load(completion: handleFeedResult)
    }
    
    func next() {
        guard let loadNext = loadNext else {
            return
        }
        state = .Loading(initial: false)
        loadNext(completion: handleFeedResult)
        self.loadNext = nil
    }
    
    private var loadNext: FeedResult<Page>.LoadPageBlock?
    private let stateDidChange: LoadingFeedState<Page> -> Void
    
    private func handleFeedResult(result: FeedResult<Page>) {
        switch result {
        case .Success(let page, let nextPage):
            loadNext = nextPage
            state = .Succeed(page: page)
        case .Error(let message, let retry):
            loadNext = retry
            state = .Failed(error: message)
        case .FeedEnd:
            loadNext = nil
            state = .Ended
        }
    }
}
