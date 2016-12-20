//
//  ItemsCollectionViewLayout.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 07/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

let ItemsCollectionFooterSupplementaryKind = "ItemsCollectionFooterSupplementaryKind"


class ItemsCollectionViewLayout: ColumnFeedCollectionViewLayout {
    
    fileprivate static let bottomSupplementaryViewIndexPath: IndexPath = IndexPath(index: 0)
    
    fileprivate var bottomSupplementaryViewAtt: UICollectionViewLayoutAttributes!
    
    // MARK: - Overridden
    
    override func prepare() {
        super.prepare()
        
        bottomSupplementaryViewAtt = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: ItemsCollectionFooterSupplementaryKind,
            with: ItemsCollectionViewLayout.bottomSupplementaryViewIndexPath)
        
        let superContentSize = super.collectionViewContentSize()
        bottomSupplementaryViewAtt.frame = CGRect(
            x: 0, y: superContentSize.height, width: superContentSize.width, height: 44)
    }
    
    override var collectionViewContentSize : CGSize {
        let superContentSize = super.collectionViewContentSize()
        return CGSize(width: superContentSize.width,
                      height: superContentSize.height + bottomSupplementaryViewAtt.frame.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let superAttributes = super.layoutAttributesForElements(in: rect) ?? []
        guard bottomSupplementaryViewAtt.frame.intersects(rect) else {
            return superAttributes
        }
        return [bottomSupplementaryViewAtt] + superAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == ItemsCollectionFooterSupplementaryKind
            && indexPath == ItemsCollectionViewLayout.bottomSupplementaryViewIndexPath else {
                return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
        return bottomSupplementaryViewAtt
    }
}
