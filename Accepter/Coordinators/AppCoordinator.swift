//
//  AppCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var rootViewController: UIViewController {
        return window.rootViewController ?? UIViewController()
    }
    weak var parentCoordinator: Coordinator?
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let vc = LoginViewController.instantiate(fromStoryboard: "Login")
        vc.coordinator = self
        window.rootViewController = vc
    }
    
    func login() {
        let main = MainCoordinator(tabBarController: MainTabBarController())
        main.start()
        main.parentCoordinator = self
        childCoordinators.append(main)
        window.rootViewController = main.tabBarController
    }
    
    func logout() {
        childCoordinators.removeAll()
        start()
    }
}
