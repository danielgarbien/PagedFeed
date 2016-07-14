//
//  ItemsCollectionBottomReusableView+LoadingFeedState.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 09/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

extension ItemsCollectionBottomReusableView {
    
    func updateWithLoadingState<T>(loadingState: LoadingFeedState<T>) {
        switch loadingState {
        case .Idle, .Succeed:
            state = .Idle
        case .Loading:
            state = .InProgress
        case .Failed(let error):
            switch error {
            case SynchronizerError.WrongStatusError(403):
                state = .TryAgain(message: "Non-authenticated requests rate limit exceeded.")
            case SynchronizerError.URLSessionError(let other):
                state = .TryAgain(message: other.localizedDescription)
            default:
                state = .TryAgain(message: "Something went wrong.")
            }
        case .Ended:
            state = .TheEnd
        }
    }
}
