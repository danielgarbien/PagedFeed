//
//  UIViewController+Containment.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 11/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /**
     Add childController with no transition.
     Embeds its view in container.
     Calls didMoveToParentViewController on childController at a last step.
     */
    func addImmediatelyChildViewController(_ childController: UIViewController, embeddedInView container: UIView, belowSubview: UIView? = nil) {
        addChildViewController(childController)
        container.embedSubview(childController.view, belowView:belowSubview)
        childController.didMove(toParentViewController: self)
    }
    
    func removeImmediatelyFromParentViewController() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}


extension UIView {
    
    func embedSubview(_ view: UIView, belowView: UIView? = nil) {
        if let topView = belowView {
            insertSubview(view, belowSubview: topView)
        }
        else {
            addSubview(view)
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraintsForItem(view, withEqualFrameAsItem: self)
    }
}


extension NSLayoutConstraint {
    
    static func activateConstraintsForItem(_ item: AnyObject, withEqualFrameAsItem secondItem: AnyObject) {
        activate(
            constraintsForItem(
                item,
                withEqualAttributes: [.left, .right, .top, .bottom],
                toItem: secondItem)
        )
    }
    
    static func constraintsForItem(_ item: AnyObject, withEqualAttributes attributes: [NSLayoutAttribute], toItem: AnyObject) -> [NSLayoutConstraint] {
        return attributes.map {
            return NSLayoutConstraint(item: item, withEqualAttribute: $0, toItem: toItem)
        }
    }
    
    convenience init(item: AnyObject, withEqualAttribute attribute: NSLayoutAttribute, toItem: AnyObject) {
        self.init(item: item, attribute: attribute, relatedBy: .equal, toItem: toItem, attribute: attribute, multiplier: 1, constant: 0)
    }
}
