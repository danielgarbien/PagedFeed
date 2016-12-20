//
//  AppDelegate.swift
//  PagedFeed
//
//  Created by Daniel Garbień on 29/05/16.
//  Copyright © 2016 Daniel Garbień. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        window?.rootViewController = itemsViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

private let oneHour: TimeInterval = 60 * 60

private extension AppDelegate {
    
    func itemsViewController() -> UIViewController {
        let baseURL = URL(string: Bundle.main.apiBaseUrl())!
        let dataAccess = NetworkDataAccess(baseURL: baseURL, cacheTime: oneHour)
        let imageAccess = NetworkImageAccess(cacheTime: 24 * oneHour)
        return SearchUsersViewController(dataAccess: dataAccess, imageAccess: imageAccess)
    }
}
