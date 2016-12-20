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
    let URL: Foundation.URL
}

extension ImageResource: Resource {
    
    func request() -> URLRequest {
        return URLRequest(url: URL)
    }
    
    var parse: (Data) throws -> UIImage? {
        return { data in
            UIImage(data: data)
        }
    }
}
