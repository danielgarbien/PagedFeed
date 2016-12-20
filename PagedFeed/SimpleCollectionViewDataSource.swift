//
//  SimpleCollectionViewDataSource.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 05/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit


class SimpleCollectionViewDataSource<Cell: AnyObject, Object>: NSObject, UICollectionViewDataSource {
    
    var objects: [[Object]]
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
        return objects[indexPath.section][indexPath.row]
    }
    
    typealias ConfigureCellBlock = (Cell, Object) -> Void

    init(objects: [[Object]], cellType: CellType, configureCell: @escaping ConfigureCellBlock) {
        self.objects = objects
        self.configureCell = configureCell
        cellRegistration = CollectionRegistrationState(resiterBlock: cellType.registerBlock())
    }
    
    fileprivate let configureCell: ConfigureCellBlock
    fileprivate var cellRegistration: CollectionRegistrationState
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellRegistration.reuseIdentifierForClass(Cell.self, inCollectionView: collectionView),
            for: indexPath)
        configureCell(cell as! Cell, objectAtIndexPath(indexPath))
        return cell
    }
}


enum CellType {
    case nib
    case `class`
    
    func registerBlock() -> RegisterBlock {
        return { collectionView, cellClass -> String in
            let identifier = String(describing: cellClass)
            switch self {
            case .nib:
                collectionView.register(UINib(nibName: String(describing: cellClass), bundle: nil), forCellWithReuseIdentifier: identifier)
            case .class:
                collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
            }
            return identifier
        }
    }
}
