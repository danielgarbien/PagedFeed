//
//  ItemsCollectionBottomReusableView+LoadingFeedState.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 09/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension ItemsCollectionBottomReusableView {
    
    func updateWithLoadingState<T>(_ loadingState: LoadingFeedState<T>) {
        switch loadingState {
        case .idle, .succeed:
            state = .idle
        case .loading:
            state = .inProgress
        case .failed(let error):
            switch error {
            case SynchronizerError.wrongStatusError(403):
                state = .tryAgain(message: "Non-authenticated requests rate limit exceeded.")
            case SynchronizerError.urlSessionError(let other):
                state = .tryAgain(message: other.localizedDescription)
            default:
                state = .tryAgain(message: "Something went wrong.")
            }
        case .ended:
            state = .theEnd
        }
    }
}
