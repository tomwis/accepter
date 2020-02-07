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
    var tabBarController: MainTabBarController {
        return rootViewController as! MainTabBarController
    }
    weak var parentCoordinator: Coordinator?
    
    var previousTabIndex: Int = 0
    
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
        
        let cameraCoordinator = setupTabChildCoordinator(coordinator: CameraCoordinator(navigationController: UINavigationController()),
                                                          title: "Camera",
                                                          iconName: "Camera",
                                                          exposed: true)
        
        let expenseListCoordinator = setupTabChildCoordinator(coordinator: ExpenseListCoordinator(navigationController: UINavigationController()),
                                                              title: "Expenses",
                                                              iconName: "dollarsign.circle.fill")
        
        let settingsCoordinator = setupTabChildCoordinator(coordinator: SettingsCoordinator(navigationController: UINavigationController()),
                                                           title: "Settings",
                                                           iconName: "gear")
        
        childCoordinators.append(homeCoordinator)
        childCoordinators.append(expenseCoordinator)
        childCoordinators.append(cameraCoordinator)
        childCoordinators.append(expenseListCoordinator)
        childCoordinators.append(settingsCoordinator)
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            expenseCoordinator.navigationController,
            cameraCoordinator.rootViewController,
            expenseListCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]
        
        tabBarController.tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBarController.coordinator = self
    }
    
    func setupTabChildCoordinator<T>(coordinator: T, title: String, iconName: String, exposed: Bool = false) -> T where T: Coordinator {
        coordinator.start()
        coordinator.parentCoordinator = self
        
        var vc = coordinator.rootViewController
        
        if let navController = coordinator.rootViewController as? UINavigationController,
            let topVc = navController.topViewController {
            vc = topVc
        }
        
        vc.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: iconName), selectedImage: UIImage(systemName: iconName))
        
        if exposed {
            vc.tabBarItem.image = UIImage(named: iconName)
            vc.tabBarItem.imageInsets = UIEdgeInsets(top: -8, left: 0, bottom: 8, right: 0)
        }
        
        return coordinator
    }
    
    func goHome() {
        tabBarController.selectedIndex = 0
        previousTabIndex = 0
    }
    
    func goToNewExpense() {
        tabBarController.selectedIndex = 1
        previousTabIndex = 1
    }
    
    func goToNewExpense(image: UIImage) {
        
        if let navVc = childCoordinators[1].rootViewController as? UINavigationController,
            let vc = navVc.topViewController as? ExpenseViewController {
            vc.imageFromCamera = image
        }
        
        tabBarController.selectedIndex = 1
    }
    
    func goToExpenseList(tabIndex: Int) {
        
        if let navVc = childCoordinators[3].rootViewController as? UINavigationController {
            navVc.popToRootViewController(animated: false)
            
            if let vc = navVc.topViewController as? ExpenseListViewController {
                vc.viewModel.selectedTabIndex.value = tabIndex
            }
        }
        
        tabBarController.selectedIndex = 3
        previousTabIndex = 3
    }
    
    func goToExpenseList(newExpense: Expense) {
        
        if let navVc = childCoordinators[3].rootViewController as? UINavigationController {
            navVc.popToRootViewController(animated: false)
            
            if let vc = navVc.topViewController as? ExpenseListViewController {
                vc.newExpense = newExpense
            }
        }
        
        tabBarController.selectedIndex = 3
        previousTabIndex = 3
    }
    
    func goToSettings() {
        tabBarController.selectedIndex = 4
        previousTabIndex = 4
    }
    
    func returnToLastTab() {
        tabBarController.selectedIndex = previousTabIndex
    }
    
    func logout() {
        if let parent = parentCoordinator as? AppCoordinator {
            parent.logout()
        }
    }
}
