//
//  SettingsViewModel.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import Bond

class SettingsViewModel {
    let authorizationService: AuthorizationService
    let localStorageService: LocalStorageService
    let userService: UserService
    var user = Observable<User?>(nil)
    
    init(userService: UserService, authorizationService: AuthorizationService, localStorageService: LocalStorageService) {
        self.userService = userService
        self.authorizationService = authorizationService
        self.localStorageService = localStorageService
        
        do {
            try userService.getUserData { (user) in
                self.user.value = user
            }
        } catch {
            print("SettingsViewModel - getUserData - error: \(error)")
        }
    }
    
    func logout() {
        authorizationService.token = nil
        localStorageService.invalidateNotificationTokens()
        try? localStorageService.deleteAllData()
    }
}
