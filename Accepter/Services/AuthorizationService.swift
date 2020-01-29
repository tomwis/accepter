//
//  AuthorizationService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 22/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import RealmSwift

class AuthorizationService {
//    var user: User?
    var token: Token?
    let webRequestService: WebRequestService
    
    init(webRequestService: WebRequestService) {
        self.webRequestService = webRequestService
    }
    
    func login(login: String, password: String, completionHandler: @escaping (Bool) -> Void) throws {
        let data = LoginRequest(grantType: "password", username: login, password: password, clientId: "", clientSecret: "")
        try webRequestService.post(url: "\(AppSettings.baseUrl)\(AppSettings.loginUrl)", data: data) { (result: LoginResponse?) in
            print("Login respose: \(result)")
            
            if let result = result {
                self.token = Token(accessToken: result.accessToken, tokenType: result.tokenType, expiresIn: result.expiresIn)
                completionHandler(true)
            } else {
                self.token = nil
                completionHandler(false)
            }
            
//            if result?.accessToken != nil {
//                DispatchQueue.main.async {
//                    do {
//                        let realm = try Realm()
//                        self.user = realm.objects(User.self).filter(NSPredicate(format: "login == %@", login)).first!
//                        completionHandler(true)
//                    } catch {
//                        print("Error when getting user from db: \(error)")
//                    }
//                }
//            } else {
//                completionHandler(false)
//            }
        }
    }
}
