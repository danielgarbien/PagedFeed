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
    
    init(dataAccess: DataAccess) {
        self.dataAccess = dataAccess
        super.init(nibName: nil, bundle: nil)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addImmediatelyChildViewController(navController, embeddedInView: view)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUsersVC()
    }
    
    private let dataAccess: DataAccess
    
    // MARK: - Controllers
    private lazy var usersVC: UsersCollectionViewController
        = UsersCollectionViewController(searchBar: self.searchBar(),
                                        switchControl: self.userTypeSwitch())
    private lazy var navController: UINavigationController
        = UINavigationController(rootViewController: self.usersVC,
                                 hidesBarsOnSwipe: true)
    
    // MARK: - Search
    private var searchTerm: String? {
        didSet { updateUsersVC() }
    }
    private var usersSort: UsersResourceSort = .BestMatch {
        didSet { updateUsersVC() }
    }
}

private extension SearchUsersViewController {
    
    func updateUsersVC() {
        guard let searchTerm = searchTerm where searchTerm.characters.count > 0 else {
            usersVC.reset()
            return
        }
        usersVC.startFeed { limit -> FeedResult<[User]>.LoadPageBlock in
            // knowing page limit desired by Items VC, create load function and pass to Items VC
            func load(completion: (FeedResult<[User]> -> Void)) {
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
        searchBar.autocapitalizationType = .None
        searchBar.tintColor = UIColor.myGreyColor()
        searchBar.placeholder = "Search"
        return searchBar
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
    }
}

private extension SearchUsersViewController {
    
    func userTypeSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.onTintColor = UIColor.myRedColor()
        switchControl.on = .ByFollowers ~= usersSort
        switchControl.addTarget(self, action: #selector(SearchUsersViewController.switchChanged(_:)), forControlEvents: .ValueChanged)
        return switchControl
    }
    
    @objc func switchChanged(sender: UISwitch) {
        usersVC.updateWithSwitchChanged(sender)
        usersSort = sender.on ? .ByFollowers : .BestMatch
    }
}

private extension UsersCollectionViewController {
    
    convenience init(searchBar: UISearchBar, switchControl: UISwitch) {
        self.init()
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switchControl)
        updateWithSwitchChanged(switchControl)
    }
    
    func updateWithSwitchChanged(switchControl: UISwitch) {
        navigationItem.prompt = switchControl.on ? "Sort by followers" : "Best match"
    }
}

private extension UINavigationController {
    
    convenience init(rootViewController: UIViewController, hidesBarsOnSwipe: Bool) {
        self.init(rootViewController: rootViewController)
        self.hidesBarsOnSwipe = hidesBarsOnSwipe
    }
}
