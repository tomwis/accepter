//
//  SettingsViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var userDataLabel: UILabel!
    weak var coordinator: SettingsCoordinator?
    let viewModel = AppDelegate.container.resolve(SettingsViewModel.self)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBindings()
    }
    
    func initBindings() {
        viewModel.user
            .map({ (user) -> String? in
                if let user = user {
                    return """
                    Name: \(user.name)
                    Login: \(user.login)
                    Email: \(user.email)
                    Approver: \(user.approverId ?? "none")
                    Subordinates: \(user.approverForUserIds.joined(separator: ", "))
                    """
                }
                
                return nil
            })
            .bind(to: userDataLabel.reactive.text)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        viewModel.logout()
        coordinator?.logout()
    }
}
