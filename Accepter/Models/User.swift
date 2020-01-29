//
//  User.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 22/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    convenience init(name: String, login: String, email: String, approver: User? = nil) {
        self.init()
        self.name = name
        self.login = login
        self.email = email
        self.approver = approver
    }

    convenience init?(from user: User?) {
        guard let user = user else { return nil }

        self.init()
        self.id = user.id
        self.name = user.name
        self.login = user.login
        self.email = user.email
        self.approver = user.approver
        self.approverForUsers = user.approverForUsers
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var login: String = ""
    @objc dynamic var email: String = ""
    dynamic var approver: User?
    dynamic var approverForUsers = List<User>()
    let approvers = LinkingObjects(fromType: User.self, property: "approverForUsers")
    
    func hasApprover() -> Bool {
        return approver != nil
    }
    
    func isApprover() -> Bool {
        return approverForUsers.count > 0
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
