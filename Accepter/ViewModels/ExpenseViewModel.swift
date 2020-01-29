//
//  ExpenseViewModel.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond
import RealmSwift

class ExpenseViewModel {
    let title = Observable<String?>("")
    let category = Observable<String?>("")
    let amount = Observable<String?>("")
    let status = Observable<Expense.Status>(.draft)
    var expenseToModify: Expense?
    let didAdd = PassthroughSubject<Expense, Never>()
    let didModify = PassthroughSubject<Expense, Never>()
    let validationError = PassthroughSubject<(fieldName: ValidationFieldName.Expense, errorMessage: String?), Never>()
    let localStorageService: LocalStorageService
    let dialogService: DialogService
    let authorizationService: AuthorizationService
    
    
    init(localStorageService: LocalStorageService, dialogService: DialogService, authorizationService: AuthorizationService) {
        self.localStorageService = localStorageService
        self.dialogService = dialogService
        self.authorizationService = authorizationService
                
        initValidationObservers()
    }
    
    func initExpense(_ expense: Expense?) {
        expenseToModify = expense
        
        if let expense = expense {
            title.value = expense.title
            category.value = expense.category
            amount.value = String(expense.amount)
            status.value = expense.status
        }
    }
    
    private func initValidationObservers() {
        _ = title.observeNext { (text) in
            _ = self.validationIsEmpty(text: text, fieldName: .title)
        }
        
        _ = category.observeNext { (text) in
            _ = self.validationIsEmpty(text: text, fieldName: .category)
        }
        
        _ = amount.observeNext { (text) in
            _ = self.validationIsEmpty(text: text, fieldName: .amount)
        }
    }
    
    private func validationIsEmpty(text: String?, fieldName: ValidationFieldName.Expense) -> Bool {
        let msg = self.isNilOrEmpty(text: text) ? "Field cannot be empty" : nil
        self.validationError.send((fieldName: fieldName, errorMessage: msg))
        return msg != nil
    }
    
    private func isNilOrEmpty(text: String?) -> Bool {
        return text?.isEmpty ?? true
    }
    
    func save(sendToApproval: Bool) {
        guard !self.validationIsEmpty(text: title.value, fieldName: .title),
        !self.validationIsEmpty(text: category.value, fieldName: .category),
        !self.validationIsEmpty(text: amount.value, fieldName: .amount) else { return }
                
        guard let amountParsed = Double(amount.value!) else { return }
        let status: Expense.Status = sendToApproval ? .waitingForApproval : .draft
        
        do {
            if let expenseToModify = expenseToModify {
                try updateExpense(expenseToModify: expenseToModify,
                                  title: title.value!,
                                  category: category.value!,
                                  amount: amountParsed,
                                  status: status)
            } else {
                try addNewExpense(title: title.value!,
                                  category: category.value!,
                                  amount: amountParsed,
                                  status: status)
            }

            clearFields()
        }
        catch {
            print("Couldn't add new expense, error: \(error)")
            dialogService.showError(message: "Couldn't save expense")
        }
    }
    
    private func addNewExpense(title: String, category: String, amount: Double, status: Expense.Status) throws {
        let expense = Expense(title: title, category: category, amount: amount, status: status)
        expense.user = authorizationService.user
        expense.showInNotifications = status == .waitingForApproval
        
        try self.localStorageService.addExpense(expense)
        
        self.didAdd.send(expense)
    }
    
    private func updateExpense(expenseToModify: Expense, title: String, category: String, amount: Double, status: Expense.Status) throws {
        try localStorageService.updateExpense({
            expenseToModify.title = title
            expenseToModify.category = category
            expenseToModify.amount = amount
            expenseToModify.status = status
            expenseToModify.showInNotifications = false
        })
        
        didModify.send(expenseToModify)
    }
    
    func clearFields() {
        title.value = nil
        category.value = nil
        amount.value = nil
        
        clearValidation()
    }
    
    func clearValidation() {
        validationError.send((fieldName: .title, errorMessage: nil))
        validationError.send((fieldName: .category, errorMessage: nil))
        validationError.send((fieldName: .amount, errorMessage: nil))
    }
    
    func showSendToApprovalDialog() {
        dialogService.show(title: nil, body: "Expense was sent to approval", displayTimeInSeconds: 5)
    }
}
