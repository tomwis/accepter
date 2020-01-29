//
//  HomeViewModel.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 14/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import Bond
import RealmSwift

class HomeViewModel {
    let authorizationService: AuthorizationService
    let localStorageService: LocalStorageService
    
    var isApprovingManager = Observable<Bool>(false)
    var toSend = Observable<Int>(0)
    var toApprove = Observable<Int>(0)
    var newlyApproved = Observable<Int>(0)
    var newlyRejected = Observable<Int>(0)
    
    init(authorizationService: AuthorizationService, localStorageService: LocalStorageService) {
        self.authorizationService = authorizationService
        self.localStorageService = localStorageService
        
        initProperties()
        initExpenseCounts()
    }
    
    private func initProperties() {
        if let user = authorizationService.user {
            self.isApprovingManager.value = user.isApprover()
        }
    }
    
    private func initExpenseCounts() {
        do {            
            let expenses = try localStorageService.loadExpenses()
            let token1 = expenses.observe { (changes) in
                switch changes {
                case .initial:
                    break
                case .update(let results, _, _, _):
                    self.updateExpenseCounts(expenses: results)
                case .error(let error):
                    break
                }
            }
            localStorageService.addNotificationToken(token1)
            updateExpenseCounts(expenses: expenses)


            let expensesToApprove = try localStorageService.loadExpensesToApprove()
            let token2 = expensesToApprove.observe { (changes) in
                switch changes {
                case .initial:
                    break
                case .update(let results, _, _, _):
                    self.updateExpenseCounts(expensesToApprove: results)
                case .error(let error):
                    break
                }
            }
            localStorageService.addNotificationToken(token2)
            updateExpenseCounts(expensesToApprove: expensesToApprove)
            
        } catch {
            print("Error when loading dashboard items: \(error)")
        }
    }
    
    private func updateExpenseCounts(expenses: Results<Expense>? = nil, expensesToApprove: Results<Expense>? = nil) {

        if let expenses = expenses {
            toSend.value = expenses.filter { (expense) -> Bool in
                expense.status == .draft
            }.count
            
            newlyApproved.value = expenses.filter { (expense) -> Bool in
                expense.status == .approved && expense.showInNotifications
            }.count
            
            newlyRejected.value = expenses.filter { (expense) -> Bool in
                expense.status == .rejected && expense.showInNotifications
            }.count
        }
        
        if let expensesToApprove = expensesToApprove {
            toApprove.value = expensesToApprove.count
        }        
    }
}
