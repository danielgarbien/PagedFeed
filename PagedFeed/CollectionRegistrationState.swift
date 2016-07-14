//
//  CollectionRegistrationState.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 14/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

typealias RegisterBlock = (collectionView: UICollectionView, aClass: AnyClass) -> String // returns registered identifier

/**
 Helper enum to be used to register cell just once and than use it's identifier to dequeue from collection view.
 */
enum CollectionRegistrationState {
    case NotRegistered(RegisterBlock)
    case Registered(identifier: String)
    
    init(resiterBlock: RegisterBlock) {
        self = .NotRegistered(resiterBlock)
    }
    
    mutating func reuseIdentifierForClass(cellClass: AnyClass, inCollectionView collectionView: UICollectionView) -> String {
        switch self {
        case .NotRegistered(let register):
            let identifier = register(collectionView: collectionView, aClass: cellClass)
            self = .Registered(identifier: identifier)
            return identifier
        case .Registered(let identifier):
            return identifier
        }
    }
}
