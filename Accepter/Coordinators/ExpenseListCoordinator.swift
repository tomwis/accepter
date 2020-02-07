//
//  ExpenseListCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

import UIKit

class ExpenseListCoordinator: ExpenseEditCoordinator {
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
        let vc = ExpenseListViewController.instantiate(fromStoryboard: "ExpenseList")
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToDetails(_ expense: Expense) {
        let vc = ExpenseViewController.instantiate(fromStoryboard: "Expense")
        vc.coordinator = self
        vc.expense = expense
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goBackToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func goBackToRoot(expenseToDelete: Expense) {
        navigationController.popToRootViewController(animated: true)
        
        if let vc = navigationController.topViewController as? ExpenseListViewController {
            vc.expenseToDelete = expenseToDelete
        }
    }
}
