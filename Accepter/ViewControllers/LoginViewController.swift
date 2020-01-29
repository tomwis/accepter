//
//  LoginViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 18/12/2019.
//  Copyright © 2019 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Bond

class LoginViewController: UIViewController, Storyboarded {    

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    weak var coordinator: AppCoordinator?
    let viewModel = AppDelegate.container.resolve(LoginViewModel.self)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        initBindings()
    }
    
    func initBindings() {
        viewModel.username.bidirectionalBind(to: loginField.reactive.text)
        viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
        _ = viewModel.didSignIn.observeNext { (_) in
            self.coordinator?.login()
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel.login()
    }
}
