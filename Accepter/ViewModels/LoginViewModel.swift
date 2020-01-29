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
    }
    var token1: NotificationToken?
    func login() {
        guard let username = username.value,
            let password = password.value,
            !username.isEmpty,
            !password.isEmpty else { return }
            
        do {
            try authorizationService.login(login: username, password: password) { loginSucceeded in
                if loginSucceeded {
                    self.didSignIn.send()
//                    try! self.userService.getUserData { (user) in
//                        if let user = user {
//                            DispatchQueue.main.async {
//                                self.didSignIn.send()
////                                self.token1 = try! self.localStorageService.deleteUsersAndObserveChanges().observe { (obj) in
////                                    print("user.observe \(obj)")
////                                    switch obj {
////                                    case .initial(_):
////                                        break
////                                    case .update(let results, let deletions, let insertions, let modifications):
////                                        print("user.observe, results.count: \(results.count), deletions: \(deletions), insertions: \(insertions), modifications: \(modifications)")
////                                        if insertions.count == 1 && modifications.count == 0 && results.count == 1 {
////                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
////                                                self.token1?.invalidate()
////                                                self.didSignIn.send()
////                                            }
////                                        }
////                                        break
////                                    case .error(_):
////                                        break
////                                    }
////
////                                }
////                                self.localStorageService.addNotificationToken(self.token1!)
////                            }
////                            try! self.localStorageService.saveCurrentUser(user: user) { () in
//
//                            }
//                        }
//                    }
                } else {
                    DispatchQueue.main.async {
                        self.dialogService.showError(message: "Error occurred. Please try again.")
                    }
                }
//                DispatchQueue.main.async {
//                    if loginSucceeded {
//                        self.didSignIn.send()
//                    } else {
//                        self.dialogService.showError(message: "Error occurred. Please try again.")
//                    }
//                }
            }
        } catch {
            print("Error when logging in: \(error)")
            dialogService.showError(message: "Error occurred. Please try again.")
        }
    }
}
