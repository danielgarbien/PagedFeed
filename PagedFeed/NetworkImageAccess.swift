//
//  NetworkImageAccess.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

private let MB = 1024 * 1024

class NetworkImageAccess {

    private let synchronizer: Synchronizer
    
    init(cacheTime: NSTimeInterval) {
        self.synchronizer = Synchronizer(
            cacheTime: cacheTime,
            URLCache: NSURLCache(memoryCapacity: 100 * MB, diskCapacity: 100 * MB, diskPath: "images")
        )
    }
}

extension NetworkImageAccess: ImageAccess {
    
    func imageWithURL(URL: NSURL, completion: UIImage? -> Void) -> CancelImageLoading {
        return synchronizer.loadResource(ImageResource(URL: URL)) { (object) in
            switch object {
            case .Error: completion(nil)
            case .NoData: completion(nil)
            case .Success(let image): completion(image)
            }
        }
    }
}
