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
    
    typealias ConfigureBottomViewBlock = (ItemsCollectionBottomReusableView) -> Void
    typealias ConfigureCell = (ItemCollectionViewCell, Item) -> Void

    fileprivate(set) var footerView: ItemsCollectionBottomReusableView?
    let configureBottomView: ConfigureBottomViewBlock
    
    init(objects: [[Item]], configureCell: @escaping ConfigureCell, configureBottomView: @escaping ConfigureBottomViewBlock) {
        self.configureBottomView = configureBottomView
        super.init(objects: objects, cellType: .nib) { (cell, object) in
            configureCell(cell, object)
        }
    }
    
    fileprivate var supplementaryRegistration = CollectionRegistrationState(resiterBlock: registerSupplementaryView)
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = supplementaryRegistration.reuseIdentifierForClass(ItemsCollectionBottomReusableView.self, inCollectionView: collectionView)
        footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? ItemsCollectionBottomReusableView
        configureBottomView(footerView!)
        return footerView!
    }
}

// MARK: - Registration functions

private func registerSupplementaryView(_ collectionView: UICollectionView, viewClass: AnyClass) -> String {
    let identifier = String(describing: viewClass)
    collectionView.register(UINib(nibName: "ItemsCollectionBottomReusableView", bundle: nil),
                               forSupplementaryViewOfKind: ItemsCollectionFooterSupplementaryKind,
                               withReuseIdentifier: identifier)
    return identifier
}
