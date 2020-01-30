//
//  ExpensesService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 29/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import RealmSwift

class ExpensesService {
    let webRequestService: WebRequestService
    let localStorageService: LocalStorageService
    
    init(webRequestService: WebRequestService, localStorageService: LocalStorageService) {
        self.webRequestService = webRequestService
        self.localStorageService = localStorageService
    }
    
    func getExpenses(_ completionHandler: @escaping (Results<Expense>) -> Void) throws {
        let expenses = try localStorageService.loadExpenses()
        
        if expenses.count > 0 {
            completionHandler(expenses)
        } else {
            try webRequestService.get(url: AppSettings.baseUrl + AppSettings.expensesUrl) { (expenses: [Expense]?) in
                if let expenses = expenses {
                    DispatchQueue.main.async {
                        try? self.localStorageService.saveExpenses(expenses)
                        let expensesResult = try! self.localStorageService.loadExpenses()
                        completionHandler(expensesResult)
                    }
                }
            }
        }
    }
    
    func getExpensesToApprove(_ completionHandler: @escaping (Results<Expense>) -> Void) throws {
        let expenses = try localStorageService.loadExpensesToApprove()
        
        if expenses.count > 0 {
            completionHandler(expenses)
        } else {
            try webRequestService.get(url: AppSettings.baseUrl + AppSettings.expensesToApproveUrl) { (expenses: [Expense]?) in
                if let expenses = expenses {
                    DispatchQueue.main.async {
                        try? self.localStorageService.saveExpenses(expenses)
                        let expensesResult = try! self.localStorageService.loadExpensesToApprove()
                        completionHandler(expensesResult)
                    }
                }
            }
        }
    }
}
