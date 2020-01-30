//
//  LoginViewModel.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 13/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import RealmSwift

class LoginViewModel {
    let username = Observable<String?>("")
    let password = Observable<String?>("")
    let didSignIn = PassthroughSubject<Void, Never>()
    let authorizationService: AuthorizationService
    let dialogService: DialogService
    let localStorageService: LocalStorageService
    let userService: UserService
    
    init(authorizationService: AuthorizationService, userService: UserService, localStorageService: LocalStorageService, dialogService: DialogService) {
        self.authorizationService = authorizationService
        self.userService = userService
        self.localStorageService = localStorageService
        self.dialogService = dialogService
        
        username.value = "user1"
        password.value = "password"
        
        do {
            try localStorageService.deleteAllData()
        } catch {
            print("Error when clearing database: \(error)")
        }
    }
    
    func login() {
        guard let username = username.value,
            let password = password.value,
            !username.isEmpty,
            !password.isEmpty else { return }
            
        do {
            try authorizationService.login(login: username, password: password) { loginSucceeded in
                if loginSucceeded {
                    try! self.userService.getUserData { (user) in
                        if let _ = user {
                            DispatchQueue.main.async {
                                self.didSignIn.send()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.dialogService.showError(message: "Error occurred. Please try again.")
                    }
                }
            }
        } catch {
            print("Error when logging in: \(error)")
            dialogService.showError(message: "Error occurred. Please try again.")
        }
    }
}
