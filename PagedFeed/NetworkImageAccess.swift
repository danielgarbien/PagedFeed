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

    fileprivate let synchronizer: Synchronizer
    
    init(cacheTime: TimeInterval) {
        self.synchronizer = Synchronizer(
            cacheTime: cacheTime,
            URLCache: URLCache(memoryCapacity: 100 * MB, diskCapacity: 100 * MB, diskPath: "images")
        )
    }
}

extension NetworkImageAccess: ImageAccess {
    
    func imageWithURL(_ URL: Foundation.URL, completion: @escaping (UIImage?) -> Void) -> CancelImageLoading {
        return synchronizer.loadResource(ImageResource(URL: URL)) { (object) in
            switch object {
            case .error: completion(nil)
            case .noData: completion(nil)
            case .success(let image): completion(image)
            }
        }
    }
}
