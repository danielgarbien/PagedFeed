//
//  UsersCollectionViewController.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 14/07/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

class UsersCollectionViewController: ItemsCollectionViewController<User> {
    
    init() {
        super.init(
            configureCell: { cell, user in
                cell.configureWithUser(user)
            },
            estimatedCellHeight: ItemCollectionViewCell.estimatedHeight(),
            preferredCellHeight: ItemCollectionViewCell.preferredHeightWithUser)
    }
}

private extension ItemCollectionViewCell {
    
    func configureWithUser(user: User) {
        contentLabel.text = user.login
        bottomSubtitle.text = String(user.type)
        bottomTitle.text = String(user.score)
    }
    
    static func preferredHeightWithUser(user: User) -> CGFloat {
        return CGFloat(user.score) * 5 + 64
    }
    
    static func estimatedHeight() -> CGFloat {
        // roughly looking at handful of Item objects I guess an avarage size attribute at 30
        return 30 * 5 + 64
    }
}
