//
//  ColumnFeedCollectionViewLayout.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 07/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

struct ColumnFeedMetrics {
    let minColumnWidth: CGFloat
    let interColumnSpacing: CGFloat
    let interItemSpacing: CGFloat
    let margin: CGFloat
}

class ColumnFeedCollectionViewLayout: UICollectionViewLayout {
    
    typealias ItemHeightAtIndexPath = (IndexPath) -> CGFloat
    let itemHeight: ItemHeightAtIndexPath
    let metrics: ColumnFeedMetrics
    
    init(metrics: ColumnFeedMetrics, itemHeight: @escaping ItemHeightAtIndexPath ) {
        self.metrics = metrics
        self.itemHeight = itemHeight
        super.init()
    }
    
    func estimatedItemsCountWithEstimatedItemHeight(_ height: CGFloat, toFillContentSize size: CGSize) -> Int {
        var layoutMetrics = ColumnLayoutMetrics(feedMetrics: metrics, width: size.width)
        let horizontal = layoutMetrics.columnsCount
        let vertical = Int(size.height / (height + metrics.interItemSpacing)) + 1
        return horizontal * vertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var attributes: [IndexPath: UICollectionViewLayoutAttributes]! = [IndexPath: UICollectionViewLayoutAttributes]()
    fileprivate var columns: Columns!

    // MARK: - Overridden
    override func prepare() {
        super.prepare()
        
        columns = Columns(metrics: ColumnLayoutMetrics(feedMetrics: metrics, width: collectionView!.frame.width))
        
        collectionView!.indexPaths().forEach { indexPath in
            let att = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            att.frame = columns.addItemWithHeight(itemHeight(indexPath))
            attributes[indexPath] = att
        }
    }
    
    override var collectionViewContentSize : CGSize {
        return columns.size()
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        attributes = nil
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes.values.filter({
            $0.frame.intersects(rect)
        })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !collectionView!.bounds.size.equalTo(newBounds.size)
    }
}

private extension UICollectionView {
    
    func indexPaths() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for section in 0..<numberOfSections {
            for item in 0..<numberOfItems(inSection: section) {
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        return indexPaths
    }
}


private struct ColumnLayoutMetrics {
    let width: CGFloat
    let minColumnWidth: CGFloat
    let interColumnSpacing: CGFloat
    let interItemSpacing: CGFloat
    let margin: CGFloat
    
    init(width: CGFloat, minColumnWidth: CGFloat, interColumnSpacing: CGFloat, interItemSpacing: CGFloat, margin: CGFloat) {
        self.width = width
        self.minColumnWidth = minColumnWidth
        self.interColumnSpacing = interColumnSpacing
        self.interItemSpacing = interItemSpacing
        self.margin = margin
    }
    
    lazy var availableWidth: CGFloat = {
        return self.width - 2 * self.margin
    }()
    
    lazy var columnsCount: Int = {
        let widthWithExtraSpacing = self.availableWidth + self.interColumnSpacing
        let minColumnWithSpacing = self.minColumnWidth + self.interColumnSpacing
        return Int(widthWithExtraSpacing / minColumnWithSpacing)
    }()
    
    lazy var columnWidth: CGFloat = {
        precondition(self.columnsCount > 0)
        let widthForColumns = self.availableWidth - CGFloat(self.columnsCount - 1) * self.interColumnSpacing
        return widthForColumns / CGFloat(self.columnsCount)
    }()
    
    lazy var columnsOrigins: [CGPoint] = {
        return (0..<self.columnsCount).map { index -> CGPoint in
            let columnWithSpacing = self.columnWidth + self.interColumnSpacing
            let x = self.margin + columnWithSpacing * CGFloat(index)
            return CGPoint(x: x, y: self.margin)
        }
    }()
}

extension ColumnLayoutMetrics {
    
    init(feedMetrics: ColumnFeedMetrics, width: CGFloat) {
        self.init(width: width,
                  minColumnWidth: feedMetrics.minColumnWidth,
                  interColumnSpacing: feedMetrics.interColumnSpacing,
                  interItemSpacing: feedMetrics.interItemSpacing,
                  margin: feedMetrics.margin)
    }
}


/**
 Encapsulate the logic for calculating items frames placed in vertical columns.
 Every next item is being placed in the shortest column at the moment.
 */
private class Columns {
    
    let columns: [Column]
    var metrics: ColumnLayoutMetrics
    
    init(metrics: ColumnLayoutMetrics) {
        self.metrics = metrics
        let columnWidth = self.metrics.columnWidth
        columns = self.metrics.columnsOrigins.map{ origin -> Column in
            return Column(
                origin: origin,
                width: columnWidth,
                spacing: metrics.interItemSpacing)
        }
    }
    
    func addItemWithHeight(_ height: CGFloat) -> CGRect {
        let lowestColumn = columns.sorted { c1, c2 -> Bool in
            c1.nextItemOrigin().y < c2.nextItemOrigin().y
        }.first!
        return lowestColumn.addItemWithHeight(height)
    }
    
    func size() -> CGSize {
        let highestColumn = columns.sorted { c1, c2 -> Bool in
            c1.nextItemOrigin().y > c2.nextItemOrigin().y
        }.first!
        return CGSize(width: metrics.width,
                      height: highestColumn.height() + 2 * metrics.margin)
    }
}

private class Column {
    
    init(origin: CGPoint, width: CGFloat, spacing: CGFloat) {
        self.origin = origin
        self.width = width
        self.spacing = spacing
    }
    
    let origin: CGPoint
    let width: CGFloat
    let spacing: CGFloat
    var itemRects = [CGRect]()
    
    func addItemWithHeight(_ height: CGFloat) -> CGRect {
        let origin = nextItemOrigin()
        let itemRect = CGRect(origin: origin,
                              size: CGSize(width: width, height: height))
        itemRects.append(itemRect)
        return itemRect
    }
    
    func nextItemOrigin() -> CGPoint {
        guard let lastItem = itemRects.last else {
            return origin
        }
        return CGPoint(x: origin.x,
                       y: lastItem.maxY + spacing)
    }
    
    func height() -> CGFloat {
        guard let lastItem = itemRects.last else {
            return 0
        }
        return lastItem.maxY - origin.y
    }
}
