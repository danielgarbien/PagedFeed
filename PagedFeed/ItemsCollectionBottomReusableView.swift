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
        case idle
        case inProgress
        case theEnd
        case tryAgain(message: String)
    }
    
    var state: State = .idle {
        didSet {
            allOutlets.forEach{ $0.alpha = 0 }
            switch state {
            case .idle: break
            case .inProgress: activityIndicator.alpha = 1
            case .theEnd: theEndLabel.alpha = 1
            case .tryAgain(let message):
                tryAgainButton.alpha = 1
                tryAgainButton.setAttributedTitle(tryAgainAttributedTitleWithMessage(message, font: tryAgainButton.titleLabel!.font), for: UIControlState())
            }
        }
    }
    
    var tryAgainBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        state = .idle
    }
    
    fileprivate var allOutlets: [UIView] {
        return [activityIndicator, theEndLabel, tryAgainButton]
    }
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var theEndLabel: UILabel!
    @IBOutlet fileprivate weak var tryAgainButton: UIButton!
}

private extension ItemsCollectionBottomReusableView {
    
    @IBAction func tryAgainTapped() {
        tryAgainBlock?()
    }
    
    func tryAgainAttributedTitleWithMessage(_ message: String, font: UIFont) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(
            string: message,
            attributes: [.font: font, .foregroundColor: UIColor.myGreyColor()])
        mutableString.append(NSAttributedString(
            string: " Try again.",
            attributes: [.font: font, .foregroundColor: UIColor.myRedColor()])
        )
        return mutableString
    }
}
