//
//  ItemsCollectionViewDataSource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 07/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

class ItemsCollectionViewDataSource<Item>: SimpleCollectionViewDataSource<ItemCollectionViewCell, Item> {
    
    typealias ConfigureBottomViewBlock = ItemsCollectionBottomReusableView -> Void
    typealias ConfigureCell = (ItemCollectionViewCell, Item) -> Void

    private(set) var footerView: ItemsCollectionBottomReusableView?
    let configureBottomView: ConfigureBottomViewBlock
    
    init(objects: [[Item]], configureCell: ConfigureCell, configureBottomView: ConfigureBottomViewBlock) {
        self.configureBottomView = configureBottomView
        super.init(objects: objects, cellType: .Nib) { (cell, object) in
            configureCell(cell, object)
        }
    }
    
    private var supplementaryRegistration = CollectionRegistrationState(resiterBlock: registerSupplementaryView)
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let identifier = supplementaryRegistration.reuseIdentifierForClass(ItemsCollectionBottomReusableView.self, inCollectionView: collectionView)
        footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: identifier, forIndexPath: indexPath) as? ItemsCollectionBottomReusableView
        configureBottomView(footerView!)
        return footerView!
    }
}

// MARK: - Registration functions

private func registerSupplementaryView(collectionView: UICollectionView, viewClass: AnyClass) -> String {
    let identifier = String(viewClass)
    collectionView.registerNib(UINib(nibName: "ItemsCollectionBottomReusableView", bundle: nil),
                               forSupplementaryViewOfKind: ItemsCollectionFooterSupplementaryKind,
                               withReuseIdentifier: identifier)
    return identifier
}
