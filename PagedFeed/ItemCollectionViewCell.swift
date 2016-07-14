//
//  ItemCollectionViewCell.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 06/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomTitle: UILabel!
    @IBOutlet weak var bottomSubtitle: UILabel!
    
    @IBOutlet private weak var bottomStackView: UIStackView!
    
    override var highlighted: Bool {
        didSet {
            bottomView.backgroundColor = highlighted ? UIColor.myRedColor() : UIColor.myGreyColor()
        }
    }
}
