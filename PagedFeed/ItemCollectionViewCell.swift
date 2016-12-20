//
//  ItemCollectionViewCell.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 06/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    var prepareForReuseBlock: (() -> Void)?
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomTitle: UILabel!
    @IBOutlet weak var bottomSubtitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet fileprivate weak var bottomStackView: UIStackView!
    
    override var isHighlighted: Bool {
        didSet {
            bottomView.backgroundColor = isHighlighted ? UIColor.myRedColor() : UIColor.myGreyColor()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForReuseBlock?()
        prepareForReuseBlock = nil
    }
}
