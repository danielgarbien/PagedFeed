//
//  LoadingFeedStateMachine.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 09/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import UIKit

enum LoadingFeedState<Page> {
    case idle
    case loading(initial: Bool)
    case succeed(page: Page)
    case failed(error: Error)
    case ended
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
    
    fileprivate(set) var state: LoadingFeedState<Page> = .idle {
        didSet { stateDidChange(state) }
    }
    
    init(stateDidChange: @escaping (LoadingFeedState<Page>) -> Void) {
        self.stateDidChange = stateDidChange
    }
    
    func startFeed(_ load: FeedResult<Page>.LoadPageBlock) {
        state = .loading(initial: true)
        load(handleFeedResult)
    }
    
    func next() {
        guard let loadNext = loadNext else {
            return
        }
        state = .loading(initial: false)
        loadNext(handleFeedResult)
        self.loadNext = nil
    }
    
    fileprivate var loadNext: FeedResult<Page>.LoadPageBlock?
    fileprivate let stateDidChange: (LoadingFeedState<Page>) -> Void
    
    fileprivate func handleFeedResult(_ result: FeedResult<Page>) {
        switch result {
        case .success(let page, let nextPage):
            loadNext = nextPage
            state = .succeed(page: page)
        case .error(let message, let retry):
            loadNext = retry
            state = .failed(error: message)
        case .feedEnd:
            loadNext = nil
            state = .ended
        }
    }
}
