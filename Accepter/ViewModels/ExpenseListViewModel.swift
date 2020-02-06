//
//  ExpenseListViewModel.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import Bond
import RealmSwift
import ReactiveKit
import SwiftMessages

class ExpenseListViewModel {
    private var lastModified: Expense?
    private var isToApproveTabSelected: Bool {
        return selectedTabIndex.value == 3
    }
    private var currentUserId: String?
    
    let localStorageService: LocalStorageService
    let dialogService: DialogService
    let userService: UserService
    let expensesService: ExpensesService
    
    var filteredExpenseList = MutableObservableArray<Expense>([])
    var fullExpenseList = [Expense]()
    var fullExpenseListToApprove = [Expense]()
    var expenseListSignal: Signal<OrderedCollectionChangeset<Results<Expense>>, NSError>?
    var expenseListSafeSignal: SafeSignal<OrderedCollectionChangeset<Results<Expense>>>?
    var didUpdateRow = PassthroughSubject<Int, Never>()
    var isAcceptingManager = false
    var selectedTabIndex = Observable<Int>(0)
        
    init(localStorageService: LocalStorageService, dialogService: DialogService, userService: UserService, expensesService: ExpensesService) {
        self.localStorageService = localStorageService
        self.dialogService = dialogService
        self.userService = userService
        self.expensesService = expensesService
        
        classIndex = ExpenseListViewModel.counter
        ExpenseListViewModel.counter += 1

        initProperties()
        registerExpenseStatusObserver()
        loadExpenses()
    }
    
    func initProperties() {
        try! userService.getUserData { (user) in
            if let user = user {
                self.currentUserId = user.id
                self.isAcceptingManager = user.isApprover()
            }
        }
    }
    
    private func registerExpenseStatusObserver() {
        _ = selectedTabIndex.observeNext { (index) in
            
            if self.isToApproveTabSelected {
                self.filteredExpenseList.replace(with: self.fullExpenseListToApprove)
            } else {
                self.filteredExpenseList.replace(with: self.fullExpenseList.filter({ (expense) -> Bool in
                    switch self.selectedTabIndex.value {
                    case 0: return expense.status == .draft
                    case 1: return expense.status == .approved
                    case 2: return expense.status == .rejected
                    default: return false
                    }
                }))
            }
        }
    }
    
    func loadExpenses() {
        do {
            try expensesService.getExpenses({ (expenses) in
                self.localStorageService.addNotificationToken(self.registerExpensesChangesNotification(expenses))
                self.fullExpenseList = Array(expenses)
                self.filteredExpenseList.replace(with: self.fullExpenseList)
            })
            
            if isAcceptingManager {
                try expensesService.getExpensesToApprove({ (expensesToApprove) in
                    self.fullExpenseListToApprove = Array(expensesToApprove)
                    self.localStorageService.addNotificationToken(self.registerExpensesChangesNotification(expensesToApprove))
                })
            }
            
        } catch {
            print("Error when loading expenses: \(error)")
            filteredExpenseList.replace(with: [])
        }
    }
    
    private func registerExpensesChangesNotification(_ expenses: Results<Expense>) -> NotificationToken {
        return expenses.observe { (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                print("Expenses changed - inital")
                break
            case .update(let elements, let deletions, let insertions, let modifications):
                print("Expenses changed - update: deletions: \(deletions), insertions: \(insertions), modifications: \(modifications)")
                deletions.sorted { $0 > $1 }.forEach { self.expenseDeleted(at: $0) }
                insertions.forEach { self.expenseInserted(expense: elements[$0], at: $0) }
                modifications.forEach { self.expenseUpdated(at: $0) }
                break
            case .error(let error):
                print("Error when updating expenses: \(error)")
            }
        }
    }
    
    private func isExpenseMine(_ expense: Expense) -> Bool {
        return expense.userId == currentUserId
    }
    
    private func expenseDeleted(at row: Int) {
        var item: Expense
        
        if isToApproveTabSelected {
            item = fullExpenseListToApprove.remove(at: row)
        } else {
            item = fullExpenseList.remove(at: row)
        }
        
        if let index = filteredExpenseList.collection.firstIndex(of: item) {
            filteredExpenseList.remove(at: index)
        }
    }
    
    private func expenseInserted(expense: Expense, at row: Int) {
        if isExpenseMine(expense) {
            fullExpenseList.insert(expense, at: row)
        } else {
            fullExpenseListToApprove.insert(expense, at: row)
        }
        
        if isExpenseFromCurrentCategory(expense) {
            insertExpenseInCorrectOrder(expense)
        }
    }
    
    private func isExpenseFromCurrentCategory(_ expense: Expense) -> Bool {
        return expense.status == .draft && selectedTabIndex.value == 0 ||
        expense.status == .approved && selectedTabIndex.value == 1 ||
        expense.status == .rejected && selectedTabIndex.value == 2 ||
        expense.status == .waitingForApproval && selectedTabIndex.value == 3
    }
    
    private func insertExpenseInCorrectOrder(_ expense: Expense) {
        var inserted = false
        if let firstNewer = filteredExpenseList.collection.first(where: { $0.createdAt > expense.createdAt }) {
            if let index = filteredExpenseList.collection.firstIndex(of: firstNewer) {
                filteredExpenseList.insert(expense, at: index)
                inserted = true
            }
        }
        
        if !inserted {
            filteredExpenseList.append(expense)
        }
    }
    
    private func expenseUpdated(at row: Int) {
        var item: Expense?

        if isToApproveTabSelected {
            if fullExpenseListToApprove[row].status == .approved ||
                fullExpenseListToApprove[row].status == .rejected {
                item = fullExpenseListToApprove[row]
            }
        } else {
            if fullExpenseList[row].status == .waitingForApproval {
                item = fullExpenseList[row]
            } else if fullExpenseList[row].status == .draft {
                let tmp = fullExpenseList[row]
                if let filteredListRow = filteredExpenseList.collection.firstIndex(where: { (expense) -> Bool in
                    expense.id == tmp.id
                }) {
                    self.didUpdateRow.send(filteredListRow)
                }
            }
        }
        
        if let item = item,
            let index = filteredExpenseList.collection.firstIndex(of: item) {
            filteredExpenseList.remove(at: index)
        }
    }
    
    func removeExpense(at row: Int) {
        
        dialogService.hide()
        
        let expense = filteredExpenseList[row]
        
        do {
            lastModified = Expense(from: expense)
            try localStorageService.deleteExpense(expense)
            
            dialogService.show(title: nil, body: "Expense '\(lastModified!.title)' was deleted", buttonTitle: "Undo", buttonHandler: undoDelete)
        } catch {
            print("Error when deleting expense: \(error)")
            lastModified = nil
            dialogService.show(title: nil, body: "Couldn't delete expense '\(lastModified!.title)'")
        }
    }
    
    func sendToApprove(at row: Int) {
        let expense = filteredExpenseList[row]
        
        do {
            try localStorageService.updateExpense {
                expense.status = .waitingForApproval
            }
        } catch {
            print("Error when sending expense: \(error)")
            dialogService.show(title: nil, body: "Couldn't send expense '\(expense.title)'")
        }
    }
    
    func approveExpense(at row: Int) {
        let expense = fullExpenseListToApprove[row]

        do {
            try localStorageService.updateExpense {
                expense.status = .approved
                expense.showInNotifications = true
            }
            
            lastModified = expense
                        
            dialogService.show(title: nil, body: "Expense '\(lastModified!.title)' was approved", buttonTitle: "Undo", buttonHandler: undoAcceptReject)

        } catch {
            print("Error when approving expense: \(error)")
            dialogService.show(title: nil, body: "Couldn't approve expense '\(expense.title)'")
        }
    }
    
    func rejectExpense(at row: Int) {
        let expense = fullExpenseListToApprove[row]

        do {
            try localStorageService.updateExpense {
                expense.status = .rejected
                expense.showInNotifications = true
            }
            
            lastModified = expense
                        
            dialogService.show(title: nil, body: "Expense '\(lastModified!.title)' was rejected", buttonTitle: "Undo", buttonHandler: undoAcceptReject)
        } catch {
            print("Error when rejecting expense: \(error)")
            dialogService.show(title: nil, body: "Couldn't reject expense '\(expense.title)'")
        }
    }
    
    func markAsRead(_ expense: Expense) {
        do {
            try localStorageService.updateExpense {
                expense.showInNotifications = false
            }
        } catch {
            print("Error in markAsRead: \(error), expense: \(expense)")
        }
    }
    
    private func undoDelete() {
        if let expense = lastModified {
            do {
                try localStorageService.addExpense(expense)
                lastModified = nil
                dialogService.hide()
            } catch {
                print("Error when undoing deletion of expense: \(error)")
            }
        }
    }
    
    private func undoAcceptReject() {
        if let expense = lastModified {
            do {
                try localStorageService.updateExpense {
                    expense.status = .waitingForApproval
                }
                lastModified = nil
                dialogService.hide()
            } catch {
                print("Error when undoing approval of expense: \(error)")
                dialogService.show(title: nil, body: "Couldn't perform action on expense '\(expense.title)'")
            }
        }
    }
}
