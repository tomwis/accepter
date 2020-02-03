//
//  Expense.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import RealmSwift

class Expense: Object {
    convenience init(title: String, category: String, amount: Double, status: Status? = nil) {
        self.init()
        self.title = title
        self.category = category
        self.amount = amount
        self.status = status ?? .draft
    }
    
    convenience init(from expense: Expense) {
        self.init()
        self.title = expense.title
        self.category = expense.category
        self.amount = expense.amount
        self.createdAt = expense.createdAt
        self.status = expense.status
        self.user = expense.user
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var status: Status = .draft
    @objc dynamic var user: User?
    @objc dynamic var showInNotifications: Bool = false
    let attachments = List<String>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc enum Status: Int {
        case draft = 0
        case waitingForApproval = 1
        case approved = 2
        case rejected = 3
        
        func displayName() -> String {
            switch self.rawValue {
                case 0:
                    return "Draft"
                case 1:
                    return "Waiting for Approval"
                case 2:
                    return "Approved"
                case 3:
                    return "Rejected"
                default:
                    return ""
            }
        }
    }
}
