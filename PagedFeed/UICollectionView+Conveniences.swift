//
//  UICollectionView+Conveniences.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 11/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func lastItemIndexPath() -> NSIndexPath? {
        var section = numberOfSections() - 1
        while section >= 0 {
            let item = numberOfItemsInSection(section) - 1
            if item >= 0 {
                return NSIndexPath(forItem: item, inSection: section)
            }
            section -= 1
        }
        return nil
    }
}
