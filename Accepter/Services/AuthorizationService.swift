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
    var user: User?
        
    func login(login: String, password: String) throws {
        let realm = try Realm()
        user = realm.objects(User.self).filter(NSPredicate(format: "login == %@", login)).first!
    }
}
