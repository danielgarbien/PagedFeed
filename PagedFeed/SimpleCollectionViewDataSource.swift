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
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        return objects[indexPath.section][indexPath.row]
    }
    
    typealias ConfigureCellBlock = (Cell, Object) -> Void

    init(objects: [[Object]], cellType: CellType, configureCell: ConfigureCellBlock) {
        self.objects = objects
        self.configureCell = configureCell
        cellRegistration = CollectionRegistrationState(resiterBlock: cellType.registerBlock())
    }
    
    private let configureCell: ConfigureCellBlock
    private var cellRegistration: CollectionRegistrationState
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return objects.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            cellRegistration.reuseIdentifierForClass(Cell.self, inCollectionView: collectionView),
            forIndexPath: indexPath)
        configureCell(cell as! Cell, objectAtIndexPath(indexPath))
        return cell
    }
}


enum CellType {
    case Nib
    case Class
    
    func registerBlock() -> RegisterBlock {
        return { collectionView, cellClass -> String in
            let identifier = String(cellClass)
            switch self {
            case .Nib:
                collectionView.registerNib(UINib(nibName: String(cellClass), bundle: nil), forCellWithReuseIdentifier: identifier)
            case .Class:
                collectionView.registerClass(cellClass, forCellWithReuseIdentifier: identifier)
            }
            return identifier
        }
    }
}
