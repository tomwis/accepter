//
//  User.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 22/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object, Decodable {
//    convenience init(name: String, login: String, email: String, approver: User? = nil) {
//        self.init()
//        self.name = name
//        self.login = login
//        self.email = email
//        self.approver = approver
//        self.approverId = approverId
//    }
//
//    convenience init?(from user: User?) {
//        guard let user = user else { return nil }
//
//        self.init()
//        self.id = user.id
//        self.name = user.name
//        self.login = user.login
//        self.email = user.email
//        self.approver = user.approver
//        self.approverForUsers = user.approverForUsers
//    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.login = try container.decode(String.self, forKey: .login)
        self.email = try container.decode(String.self, forKey: .email)
        self.approverId = try container.decodeIfPresent(String.self, forKey: .approverId)
        if let list = try container.decodeIfPresent([String].self, forKey: .approverForUserIds) {
            self.approverForUserIds?.append(objectsIn: list)
        }
    }
    
    @objc dynamic var id: String = "" //NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var login: String = ""
    @objc dynamic var email: String = ""
//    dynamic var approver: User?
//    dynamic var approverForUsers = List<User>()
//    let approvers = LinkingObjects(fromType: User.self, property: "approverForUsers")
    @objc dynamic var approverId: String?
    let approverForUserIds: List<String>? = List<String>()
    
    func hasApprover() -> Bool {
        return approverId != nil
    }
    
    func isApprover() -> Bool {
        return (approverForUserIds?.count ?? 0) > 0
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, login, email, approverId, approverForUserIds
    }
}
