//
//  Utils.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 04/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation

func addToMainQueue(closure: () -> Void) {
    NSOperationQueue.mainQueue().addOperationWithBlock(closure)
}
