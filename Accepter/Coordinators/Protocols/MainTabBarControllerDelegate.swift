//
//  TabBarControllerDelegate.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

protocol MainTabBarControllerDelegate {
    func goHome()
    func goToNewExpense()
    func goToExpenseList()
    func goToSettings()
}
