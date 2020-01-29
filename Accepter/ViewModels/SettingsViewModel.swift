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
    var user = Observable<User?>(nil)
    
    init(authorizationService: AuthorizationService, localStorageService: LocalStorageService) {
        self.authorizationService = authorizationService
        self.localStorageService = localStorageService
        
        user.value = authorizationService.user
    }
    
    func logout() {
        authorizationService.user = nil
        localStorageService.invalidateNotificationTokens()
    }
}
