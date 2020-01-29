//
//  ExpenseViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class ExpenseViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var titleField: ValidationField!
    @IBOutlet weak var categoryField: ValidationField!
    @IBOutlet weak var amountField: ValidationField!
    @IBOutlet weak var saveAsDraftButton: UIButton!
    @IBOutlet weak var sendToApprovalButton: UIButton!
    
    weak var coordinator: Coordinator?
    let viewModel = AppDelegate.container.resolve(ExpenseViewModel.self)!
    var expense: Expense?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.initExpense(expense)
        
        initStyles()
        initBindings()
    }
    
    func initStyles() {
        titleField.field.placeholder = "Expense title"
        categoryField.field.placeholder = "Category"
        amountField.field.placeholder = "Amount"
        
        titleField.field.returnKeyType = .next
        categoryField.field.returnKeyType = .next
        amountField.field.returnKeyType = .done
        
        titleField.field.delegate = self
        categoryField.field.delegate = self
        amountField.field.delegate = self
    }
    
    func initBindings() {        
        viewModel.title.bidirectionalBind(to: titleField.field.reactive.text)
        viewModel.category.bidirectionalBind(to: categoryField.field.reactive.text)
        viewModel.amount.bidirectionalBind(to: amountField.field.reactive.text)
        
        viewModel.status.map({$0 == .draft}).bind(to: titleField.field.reactive.isEnabled)
        viewModel.status.map({$0 == .draft}).bind(to: categoryField.field.reactive.isEnabled)
        viewModel.status.map({$0 == .draft}).bind(to: amountField.field.reactive.isEnabled)
        viewModel.status.map({$0 != .draft}).bind(to: saveAsDraftButton.reactive.isHidden)
        viewModel.status.map({$0 != .draft}).bind(to: sendToApprovalButton.reactive.isHidden)
        
        _ = viewModel.didAdd.observeNext { (expense) in
            if let coordinator = self.coordinator as? ExpenseCoordinator {
                
                if expense.status == .draft {
                    coordinator.goToExpenseList(newExpense: expense)
                } else {
                    self.viewModel.showSendToApprovalDialog()
                }
            }
        }
        
        _ = viewModel.didModify.observeNext { (expense) in
            if let coordinator = self.coordinator as? ExpenseListCoordinator {
                coordinator.goBackToRoot()
            }
        }
        
        _ = viewModel.validationError.observeNext(with: { (error) in
            
            switch error.fieldName {
                case .title:
                    self.titleField.errorLabel.text = error.errorMessage
                case .category:
                    self.categoryField.errorLabel.text = error.errorMessage
                case .amount:
                    self.amountField.errorLabel.text = error.errorMessage
            }
        })
    }
    
    func clearFocus() {
        if titleField.field.canResignFirstResponder {
            titleField.field.resignFirstResponder()
        }
        
        if categoryField.field.canResignFirstResponder {
            categoryField.field.resignFirstResponder()
        }
        
        if amountField.field.canResignFirstResponder {
            amountField.field.resignFirstResponder()
        }
    }
    
    @IBAction func saveAsDraftTapped(_ sender: Any) {
        clearFocus()
        viewModel.save(sendToApproval: false)
    }
    
    @IBAction func sendToApprovalTapped(_ sender: Any) {
        clearFocus()
        viewModel.save(sendToApproval: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.clearValidation()
    }
}

extension ExpenseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField.field {
            textField.resignFirstResponder()
            categoryField.field.becomeFirstResponder()
        } else if textField == categoryField.field {
            textField.resignFirstResponder()
            amountField.field.becomeFirstResponder()
        }
        
        return true
    }
}
