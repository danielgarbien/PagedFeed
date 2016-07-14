//
//  ItemsCollectionBottomReusableView.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 07/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import UIKit

class ItemsCollectionBottomReusableView: UICollectionReusableView {

    enum State {
        case Idle
        case InProgress
        case TheEnd
        case TryAgain(message: String)
    }
    
    var state: State = .Idle {
        didSet {
            allOutlets.forEach{ $0.alpha = 0 }
            switch state {
            case .Idle: break
            case .InProgress: activityIndicator.alpha = 1
            case .TheEnd: theEndLabel.alpha = 1
            case .TryAgain(let message):
                tryAgainButton.alpha = 1
                tryAgainButton.setAttributedTitle(tryAgainAttributedTitleWithMessage(message, font: tryAgainButton.titleLabel!.font), forState: .Normal)
            }
        }
    }
    
    var tryAgainBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        state = .Idle
    }
    
    private var allOutlets: [UIView] {
        return [activityIndicator, theEndLabel, tryAgainButton]
    }
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var theEndLabel: UILabel!
    @IBOutlet private weak var tryAgainButton: UIButton!
}

private extension ItemsCollectionBottomReusableView {
    
    @IBAction func tryAgainTapped() {
        tryAgainBlock?()
    }
    
    func tryAgainAttributedTitleWithMessage(message: String, font: UIFont) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(
            string: message,
            attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.myGreyColor()])
        mutableString.appendAttributedString(NSAttributedString(
            string: " Try again.",
            attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.myRedColor()])
        )
        return mutableString
    }
}
