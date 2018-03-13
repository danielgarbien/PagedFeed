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
    
    init(configureCell: @escaping ConfigureCell, estimatedCellHeight: CGFloat, preferredCellHeight: @escaping PreferredCellHeight) {
        self.configureCell = configureCell
        self.estimatedCellHeight = estimatedCellHeight
        self.preferredCellHeight = preferredCellHeight
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startFeed(_ loadClosureWithLimit: (Int) -> FeedResult<[Item]>.LoadPageBlock) {
        loadingStateMachine.startFeed { completion in
            let load = loadClosureWithLimit(pageLimit())
            load(completion)
        }
    }
    
    func reset() {
        resetCollection()
        loadingStateMachine = createLoadingStateMachine()
    }
    
    override func loadView() {
        view = collectionView
    }
    
    // MARK: - Paging
    fileprivate lazy var loadingStateMachine = self.createLoadingStateMachine()
    private func createLoadingStateMachine() -> LoadingFeedStateMachine<[Item]> {
        return LoadingFeedStateMachine() { [weak self] state in
            switch state {
            case .loading(true): self?.resetCollection()
            case .succeed(let items, _): self?.updateCollectionByAppendingItems(items)
            default: break
            }
            self?.dataSource.footerView?.updateWithLoadingState(state)
        }
    }
    
    fileprivate func pageLimit() -> Int {
        return layout.estimatedItemsCountWithEstimatedItemHeight(
            estimatedCellHeight, toFillContentSize: view.frame.size)
    }
    
    // MARK: - Collection view
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self.collectionViewDelegate
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    // MARK: - Collection view delegate
    fileprivate lazy var collectionViewDelegate: UICollectionViewDelegate = {
        return CollectionViewDelegate {
            self.loadingStateMachine.next()
        }
    }()
    
    // MARK: - Collection view layout
    fileprivate lazy var layout: ItemsCollectionViewLayout = {
        let metrics = ColumnFeedMetrics(minColumnWidth: 120, interColumnSpacing: 16, interItemSpacing: 16, margin: 16)
        let layout = ItemsCollectionViewLayout(metrics: metrics) {
            return self.preferredCellHeight(self.dataSource.objectAtIndexPath($0))
        }
        return layout
    }()
    
    // MARK: - Collection view data source
    fileprivate lazy var dataSource: ItemsCollectionViewDataSource<Item>
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
    
    init(willDisplayLastCell: @escaping () -> Void) {
        self.willDisplayLastCell = willDisplayLastCell
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
    
    func updateCollectionByAppendingItems(_ items: [Item]) {
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
            self.dataSource.objects[0].append(contentsOf: items)
            let countAfter = self.dataSource.objects[0].count
            
            let indexPaths = (countBefore..<countAfter).map { IndexPath(item: $0, section: 0) }
            self.collectionView.insertItems(at: indexPaths)
            
            }, completion: nil)
    }
}
