//
//  ExpenseListViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Bond

class ExpenseListViewController: UIViewController, UITableViewDelegate, Storyboarded {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    weak var coordinator: ExpenseListCoordinator?
    let viewModel = AppDelegate.container.resolve(ExpenseListViewModel.self)!
    var newExpense: Expense?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initBindings()
    }
    
    func initView() {
        tableView.delegate = self
        
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "To send", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Approved", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "Rejected", at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        
        if viewModel.isAcceptingManager {
            segmentedControl.insertSegment(withTitle: "To approve", at: 3, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let newExpense = newExpense {
            if newExpense.status == .draft {
                viewModel.selectedTabIndex.value = 0
            }
            self.newExpense = nil
        }
    }
        
    func initBindings() {
        viewModel.filteredExpenseList.bind(to: tableView, createCell: initCell(_:_:_:))
        
        viewModel.selectedTabIndex.bidirectionalBind(to: segmentedControl.reactive.selectedSegmentIndex)
        
        _ = viewModel.didUpdateRow.observeNext { (row) in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
        
//        _ = viewModel.didUpdateRow.observeNext(with: { (row) in
//            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
//        })
        
//        viewModel.expenseListSignal
        
//        viewModel.expenseListSafeSignal?.bind(to: tableView, createCell: { (dataSource, indexPath, tableView) -> UITableViewCell in
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell") else {
//                fatalError()
//            }
//
//            let item = dataSource[indexPath.row]
//            cell.textLabel?.text = item.title
//            cell.detailTextLabel?.text = "\(item.category), \(item.amount) PLN"
//
//            return cell
//        })
    }
    
    func initCell(_ dataSource: [Expense], _ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell") else {
            fatalError()
        }
        
        cell.selectionStyle = .none
        let item = dataSource[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = "\(item.category), \(item.amount) PLN, \(item.status.displayName())\nCreated at: \(item.createdAt)"
        cell.backgroundColor = UIColor.clear
        
        if item.showInNotifications {
            if item.status == .approved {
                cell.backgroundColor = UIColor.systemGreen
            } else if item.status == .rejected {
                cell.backgroundColor = UIColor.systemRed
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let status = viewModel.filteredExpenseList[indexPath.row].status
        if status == .draft {
            return prepareSwipeAction(title: "Send to Approve", style: .normal, backgroundColor: UIColor.systemIndigo, systemIconName: "paperplane.fill") {
                self.viewModel.sendToApprove(at: indexPath.row)
            }
        } else if status == .waitingForApproval {
            return prepareSwipeAction(title: "Approve", style: .normal, backgroundColor: UIColor.systemGreen, systemIconName: "checkmark") {
                self.viewModel.approveExpense(at: indexPath.row)
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let status = viewModel.filteredExpenseList[indexPath.row].status
        if status == .draft {
            return prepareSwipeAction(title: "Delete", style: .destructive, backgroundColor: UIColor.systemRed, systemIconName: "trash.fill") {
                self.viewModel.removeExpense(at: indexPath.row)
            }
        } else if status == .waitingForApproval {
            return prepareSwipeAction(title: "Reject", style: .normal, backgroundColor: UIColor.systemRed, systemIconName: "xmark") {
                self.viewModel.rejectExpense(at: indexPath.row)
            }
        }
        
        return nil
    }
    
    private func prepareSwipeAction(title: String, style: UIContextualAction.Style, backgroundColor: UIColor, systemIconName: String, actionOnSwipe: @escaping () -> Void) -> UISwipeActionsConfiguration {
        let action = UIContextualAction(style: style, title: title) { (action, view, completionHandler) in
            actionOnSwipe()
            completionHandler(true)
        }
        action.backgroundColor = backgroundColor
        action.image = UIImage(systemName: systemIconName)
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let expense = viewModel.filteredExpenseList[indexPath.row]
        
        viewModel.markAsRead(expense)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        coordinator?.goToDetails(expense)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91 // Minimum height for swipe with icon and text
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath,
            viewModel.filteredExpenseList.count > indexPath.row {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
