//
//  ItemsCollectionViewController.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 05/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

class ItemsCollectionViewController<Item>: UIViewController {
    
    typealias ConfigureCell = (ItemCollectionViewCell, Item) -> Void
    typealias PreferredCellHeight = (Item) -> CGFloat
    
    let configureCell: ConfigureCell
    let preferredCellHeight: PreferredCellHeight
    let estimatedCellHeight: CGFloat
    
    init(configureCell: ConfigureCell, estimatedCellHeight: CGFloat, preferredCellHeight: PreferredCellHeight) {
        self.configureCell = configureCell
        self.estimatedCellHeight = estimatedCellHeight
        self.preferredCellHeight = preferredCellHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    func startFeed(@noescape loadClosureWithLimit: Int -> FeedResult<[Item]>.LoadPageBlock) {
        loadingStateMachine.startFeed { completion in
            let load = loadClosureWithLimit(pageLimit())
            load(completion: completion)
        }
    }
    
    func reset() {
        loadingStateMachine = nil
        resetCollection()
    }
    
    override func loadView() {
        view = collectionView
    }
    
    // MARK: - Paging
    private lazy var loadingStateMachine: LoadingFeedStateMachine<[Item]>! = LoadingFeedStateMachine(stateDidChange: self.handleLoadingStateChange)
    
    private func handleLoadingStateChange(state: LoadingFeedState<[Item]>) {
        switch state {
        case .Loading(true): resetCollection()
        case .Succeed(let items): updateCollectionByAppendingItems(items)
        default: break
        }
        dataSource.footerView?.updateWithLoadingState(loadingStateMachine.state)
    }
    
    private func pageLimit() -> Int {
        return layout.estimatedItemsCountWithEstimatedItemHeight(
            estimatedCellHeight, toFillContentSize: view.frame.size)
    }
    
    // MARK: - Collection view
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self.collectionViewDelegate
        collectionView.keyboardDismissMode = .OnDrag
        collectionView.backgroundColor = UIColor.whiteColor()
        return collectionView
    }()
    
    // MARK: - Collection view delegate
    private lazy var collectionViewDelegate: UICollectionViewDelegate = {
        return CollectionViewDelegate {
            self.loadingStateMachine.next()
        }
    }()
    
    // MARK: - Collection view layout
    private lazy var layout: ItemsCollectionViewLayout = {
        let metrics = ColumnFeedMetrics(minColumnWidth: 120, interColumnSpacing: 16, interItemSpacing: 16, margin: 16)
        let layout = ItemsCollectionViewLayout(metrics: metrics) {
            return self.preferredCellHeight(self.dataSource.objectAtIndexPath($0))
        }
        return layout
    }()
    
    // MARK: - Collection view data source
    private lazy var dataSource: ItemsCollectionViewDataSource<Item>
        = ItemsCollectionViewDataSource(objects: [[]], configureCell: self.configureCell) { [unowned self] bottomView in
            bottomView.updateWithLoadingState(self.loadingStateMachine.state)
            bottomView.tryAgainBlock = { [weak self] in
                self?.loadingStateMachine.next()
            }
    }
}

// MARK: - Scroll view delegate

private class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    let willDisplayLastCell: () -> Void
    
    init(willDisplayLastCell: () -> Void) {
        self.willDisplayLastCell = willDisplayLastCell
    }
    
    @objc func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.lastItemIndexPath() == indexPath {
            willDisplayLastCell()
        }
    }
}

// MARK: - Collection view updates

private extension ItemsCollectionViewController {
    
    func resetCollection() {
        dataSource.objects = [[]]
        collectionView.reloadData()
    }
    
    func updateCollectionByAppendingItems(items: [Item]) {
        guard dataSource.objects[0].count > 0 else {
            // if collection view has just been reset reload data with no animation
            // calling performBatchUpdates too quickly triggers internal UIKit assertion:
            // Assertion failure in -[UICollectionViewData indexPathForItemAtGlobalIndex:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit_Sim/UIKit-3512.60.7/UICollectionViewData.m:614
            dataSource.objects = [items]
            collectionView.reloadData()
            return
        }
        
        collectionView.performBatchUpdates({
            
            let countBefore = self.dataSource.objects[0].count
            self.dataSource.objects[0].appendContentsOf(items)
            let countAfter = self.dataSource.objects[0].count
            
            let indexPaths = (countBefore..<countAfter).map { NSIndexPath(forItem: $0, inSection: 0) }
            self.collectionView.insertItemsAtIndexPaths(indexPaths)
            
            }, completion: nil)
    }
}
