//
//  ImageAccess.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 17/08/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

typealias CancelImageLoading = () -> Void

protocol ImageAccess {    
    
    func imageWithURL(_ URL: URL, completion: @escaping (UIImage?) -> Void) -> CancelImageLoading
}
