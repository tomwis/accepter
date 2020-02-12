//
//  HomeViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 03/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, Storyboarded, TabBarChildController {
    
    @IBOutlet weak var toApproveView: UIView!
    @IBOutlet weak var toSendView: UIView!
    @IBOutlet weak var newlyApprovedView: UIView!
    @IBOutlet weak var newlyRejectedView: UIView!
    @IBOutlet weak var toSendLabel: UILabel!
    @IBOutlet weak var toApproveLabel: UILabel!
    @IBOutlet weak var newlyApprovedLabel: UILabel!
    @IBOutlet weak var newlyRejectedLabel: UILabel!
    
    weak var coordinator: HomeCoordinator?
    var isAuthorized = false
    var viewModel = AppDelegate.container.resolve(HomeViewModel.self)!
    
    var showTabBar: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBindings()
        
        toSendView.addGestureRecognizer(UISingleTouchGestureRecognizer(target: self, action: #selector(self.onToSendViewTapped)))
        toApproveView.addGestureRecognizer(UISingleTouchGestureRecognizer(target: self, action: #selector(self.onToApproveViewTapped)))
        newlyApprovedView.addGestureRecognizer(UISingleTouchGestureRecognizer(target: self, action: #selector(self.onNewlyApprovedViewTapped)))
        newlyRejectedView.addGestureRecognizer(UISingleTouchGestureRecognizer(target: self, action: #selector(self.onNewlyRejectedViewTapped)))
    }
    
    func initBindings() {
        viewModel.isApprovingManager.map{ !$0 }.bind(to: toApproveView.reactive.isHidden)
        viewModel.toSend.map { "To send: \($0)" }.bind(to: toSendLabel.reactive.text)
        viewModel.toApprove.map { "To approve: \($0)" }.bind(to: toApproveLabel.reactive.text)
        viewModel.newlyApproved.map { "Newly approved: \($0)" }.bind(to: newlyApprovedLabel.reactive.text)
        viewModel.newlyRejected.map { "Newly rejected: \($0)" }.bind(to: newlyRejectedLabel.reactive.text)
    }
    
    @objc func onToSendViewTapped(recognizer: UISingleTouchGestureRecognizer) {
        goToView(recognizer: recognizer, viewToAnimate: toSendView, expenseListTabIndex: 0)
    }
    
    @objc func onToApproveViewTapped(recognizer: UISingleTouchGestureRecognizer) {
        goToView(recognizer: recognizer, viewToAnimate: toApproveView, expenseListTabIndex: 3)
    }
    
    @objc func onNewlyApprovedViewTapped(recognizer: UISingleTouchGestureRecognizer) {
        goToView(recognizer: recognizer, viewToAnimate: newlyApprovedView, expenseListTabIndex: 1)
    }
    
    @objc func onNewlyRejectedViewTapped(recognizer: UISingleTouchGestureRecognizer) {
        goToView(recognizer: recognizer, viewToAnimate: newlyRejectedView, expenseListTabIndex: 2)
    }
    
    private func animateBackground(recognizer: UISingleTouchGestureRecognizer, view: UIView) {
        if recognizer.state == .began {
            view.backgroundColor = UIColor.systemGray4
        } else {
            view.backgroundColor = UIColor(named: "DashboardItemBackground")
        }
    }
    
    private func goToView(recognizer: UISingleTouchGestureRecognizer, viewToAnimate: UIView, expenseListTabIndex: Int) {
        animateBackground(recognizer: recognizer, view: viewToAnimate)
        
        if recognizer.state == .ended {
            coordinator?.goToExpenseList(tabIndex: expenseListTabIndex)
        }
    }
}
