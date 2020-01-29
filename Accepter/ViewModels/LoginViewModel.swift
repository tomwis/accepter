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
    
    init(authorizationService: AuthorizationService, localStorageService: LocalStorageService, dialogService: DialogService) {
        self.authorizationService = authorizationService
        self.localStorageService = localStorageService
        self.dialogService = dialogService
        
        username.value = "user1"
        password.value = "password"
    }

    func login() {
        guard let username = username.value,
            let password = password.value,
            !username.isEmpty,
            !password.isEmpty else { return }
            
        do {
            try authorizationService.login(login: username, password: password)
            didSignIn.send()
        } catch {
            print("Error when logging in: \(error)")
            dialogService.showError(message: "Error occurred. Please try again.")
        }
    }
}
