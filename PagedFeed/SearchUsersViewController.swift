//
//  SearchUsersViewController.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 11/06/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import Foundation
import UIKit

class SearchUsersViewController: UIViewController {
    
    init(dataAccess: DataAccess, imageAccess: ImageAccess) {
        self.dataAccess = dataAccess
        self.imageAccess = imageAccess
        super.init(nibName: nil, bundle: nil)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImmediatelyChildViewController(navController, embeddedInView: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUsersVC()
    }
    
    fileprivate let dataAccess: DataAccess
    fileprivate let imageAccess: ImageAccess
    
    // MARK: - Controllers
    fileprivate lazy var usersVC: UsersCollectionViewController
        = UsersCollectionViewController(searchBar: self.searchBar(),
                                        switchControl: self.userTypeSwitch(),
                                        imageAccess: self.imageAccess)
    fileprivate lazy var navController: UINavigationController
        = UINavigationController(rootViewController: self.usersVC,
                                 hidesBarsOnSwipe: true)
    
    // MARK: - Search
    fileprivate var searchTerm: String? {
        didSet { updateUsersVC() }
    }
    fileprivate var usersSort: UsersResourceSort = .bestMatch {
        didSet { updateUsersVC() }
    }
}

private extension SearchUsersViewController {
    
    func updateUsersVC() {
        guard let searchTerm = searchTerm, searchTerm.characters.count > 0 else {
            usersVC.reset()
            return
        }
        usersVC.startFeed { limit -> FeedResult<[User]>.LoadPageBlock in
            // knowing page limit desired by Items VC, create load function and pass to Items VC
            func load(_ completion: @escaping ((FeedResult<[User]>) -> Void)) {
                dataAccess.usersWithQuery(
                    searchTerm,
                    sort: usersSort,
                    pageSize: limit,
                    completion: completion)
            }
            return load
        }
    }
}

extension SearchUsersViewController: UISearchBarDelegate {
    
    func searchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.tintColor = UIColor.myGreyColor()
        searchBar.placeholder = "Search"
        return searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
    }
}

private extension SearchUsersViewController {
    
    func userTypeSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.onTintColor = UIColor.myRedColor()
        switchControl.isOn = .byFollowers ~= usersSort
        switchControl.addTarget(self, action: #selector(SearchUsersViewController.switchChanged(_:)), for: .valueChanged)
        return switchControl
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        usersVC.updateWithSwitchChanged(sender)
        usersSort = sender.isOn ? .byFollowers : .bestMatch
    }
}

private extension UsersCollectionViewController {
    
    convenience init(searchBar: UISearchBar, switchControl: UISwitch, imageAccess: ImageAccess) {
        self.init(imageAccess: imageAccess)
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switchControl)
        updateWithSwitchChanged(switchControl)
    }
    
    func updateWithSwitchChanged(_ switchControl: UISwitch) {
        navigationItem.prompt = switchControl.isOn ? "Sort by followers" : "Best match"
    }
}

private extension UINavigationController {
    
    convenience init(rootViewController: UIViewController, hidesBarsOnSwipe: Bool) {
        self.init(rootViewController: rootViewController)
        self.hidesBarsOnSwipe = hidesBarsOnSwipe
    }
}
