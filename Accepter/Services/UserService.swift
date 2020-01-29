//
//  UserService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 28/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

class UserService {
    let webRequestService: WebRequestService
    let localStorageService: LocalStorageService
    
    init(webRequestService: WebRequestService, localStorageService: LocalStorageService) {
        self.webRequestService = webRequestService
        self.localStorageService = localStorageService
    }
    
    func getUserData(completionHandler: @escaping (User?) -> Void) throws {
        if let user = try localStorageService.getCurrentUser() {
            completionHandler(user)
        } else {
            try webRequestService.get(url: AppSettings.baseUrl + AppSettings.userUrl) { (user: User?) in
                if let user = user {
                    try? self.localStorageService.saveCurrentUser(user: user) {
                        
                    }
                    completionHandler(user)
                }
            }
        }
    }
}
