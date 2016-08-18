//
//  ImageResource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

struct ImageResource {
    let URL: NSURL
}

extension ImageResource: Resource {
    
    func request() -> NSURLRequest {
        return NSURLRequest(URL: URL)
    }
    
    var parse: (NSData) throws -> UIImage? {
        return { data in
            UIImage(data: data)
        }
    }
}
