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
    
    private static let bottomSupplementaryViewIndexPath: NSIndexPath = NSIndexPath(index: 0)
    
    private var bottomSupplementaryViewAtt: UICollectionViewLayoutAttributes!
    
    // MARK: - Overridden
    
    override func prepareLayout() {
        super.prepareLayout()
        
        bottomSupplementaryViewAtt = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: ItemsCollectionFooterSupplementaryKind,
            withIndexPath: ItemsCollectionViewLayout.bottomSupplementaryViewIndexPath)
        
        let superContentSize = super.collectionViewContentSize()
        bottomSupplementaryViewAtt.frame = CGRect(
            x: 0, y: superContentSize.height, width: superContentSize.width, height: 44)
    }
    
    override func collectionViewContentSize() -> CGSize {
        let superContentSize = super.collectionViewContentSize()
        return CGSize(width: superContentSize.width,
                      height: superContentSize.height + bottomSupplementaryViewAtt.frame.height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let superAttributes = super.layoutAttributesForElementsInRect(rect) ?? []
        guard bottomSupplementaryViewAtt.frame.intersects(rect) else {
            return superAttributes
        }
        return [bottomSupplementaryViewAtt] + superAttributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == ItemsCollectionFooterSupplementaryKind
            && indexPath == ItemsCollectionViewLayout.bottomSupplementaryViewIndexPath else {
                return super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
        }
        return bottomSupplementaryViewAtt
    }
}
