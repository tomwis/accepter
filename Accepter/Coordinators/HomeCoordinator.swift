//
//  MainCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 13/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var rootViewController: UIViewController
    var navigationController: UINavigationController {
        return rootViewController as! UINavigationController
    }
    weak var parentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        rootViewController = navigationController
    }

    func start() {
        let vc = HomeViewController.instantiate(fromStoryboard: "Home")
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToExpenseList(tabIndex: Int) {
        if let parent = parentCoordinator as? MainCoordinator {
            parent.goToExpenseList(tabIndex: tabIndex)
        }
    }
}
