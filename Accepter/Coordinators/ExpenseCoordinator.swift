//
//  ExpenseCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class ExpenseCoordinator: ExpenseEditCoordinator {
    
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
        let vc = ExpenseViewController.instantiate(fromStoryboard: "Expense")
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToExpenseList(newExpense: Expense) {
        if let parent = parentCoordinator as? MainCoordinator {
            parent.goToExpenseList(newExpense: newExpense)
        }
    }
}
