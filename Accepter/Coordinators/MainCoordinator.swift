//
//  MainCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var rootViewController: UIViewController
    var tabBarController: UITabBarController {
        return rootViewController as! UITabBarController
    }
    weak var parentCoordinator: Coordinator?
    
    init(tabBarController: UITabBarController) {
        rootViewController = tabBarController
    }

    func start() {
        let homeCoordinator = setupTabChildCoordinator(coordinator: HomeCoordinator(navigationController: UINavigationController()),
                                                       title: "Home",
                                                       iconName: "house.fill")
        
        let expenseCoordinator = setupTabChildCoordinator(coordinator: ExpenseCoordinator(navigationController: UINavigationController()),
                                                          title: "New Expense",
                                                          iconName: "plus")
        
        let expenseListCoordinator = setupTabChildCoordinator(coordinator: ExpenseListCoordinator(navigationController: UINavigationController()),
                                                              title: "Expenses",
                                                              iconName: "dollarsign.circle.fill")
        
        let settingsCoordinator = setupTabChildCoordinator(coordinator: SettingsCoordinator(navigationController: UINavigationController()),
                                                           title: "Settings",
                                                           iconName: "gear")
        
        childCoordinators.append(homeCoordinator)
        childCoordinators.append(expenseCoordinator)
        childCoordinators.append(expenseListCoordinator)
        childCoordinators.append(settingsCoordinator)
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            expenseCoordinator.navigationController,
            expenseListCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]
    }
    
    func setupTabChildCoordinator<T>(coordinator: T, title: String, iconName: String) -> T where T: Coordinator {
        coordinator.start()
        coordinator.parentCoordinator = self
        
        var vc = coordinator.rootViewController
        
        if let navController = coordinator.rootViewController as? UINavigationController,
            let topVc = navController.topViewController {
            vc = topVc
        }
        
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: iconName), selectedImage: UIImage(systemName: iconName))
        
        return coordinator
    }
    
    func goHome() {
        tabBarController.selectedIndex = 0
    }
    
    func goToNewExpense() {
        tabBarController.selectedIndex = 1
    }
    
    func goToExpenseList(tabIndex: Int) {
        
        if let navVc = childCoordinators[2].rootViewController as? UINavigationController {
            navVc.popToRootViewController(animated: false)
            
            if let vc = navVc.topViewController as? ExpenseListViewController {
                vc.viewModel.selectedTabIndex.value = tabIndex
            }
        }
        
        tabBarController.selectedIndex = 2
    }
    
    func goToExpenseList(newExpense: Expense) {
        
        if let navVc = childCoordinators[2].rootViewController as? UINavigationController {
            navVc.popToRootViewController(animated: false)
            
            if let vc = navVc.topViewController as? ExpenseListViewController {
                vc.newExpense = newExpense
            }
        }
        
        tabBarController.selectedIndex = 2
    }
    
    func goToSettings() {
        tabBarController.selectedIndex = 3
    }
    
    func logout() {
        if let parent = parentCoordinator as? AppCoordinator {
            parent.logout()
        }
    }
}
