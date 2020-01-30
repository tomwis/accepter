//
//  LocalStorageService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 21/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import RealmSwift

class LocalStorageService {
    let authorizationService: AuthorizationService
    var notificationTokens = [NotificationToken]()
    
    init(authorizationService: AuthorizationService) {
        self.authorizationService = authorizationService
        
        checkMigrations()
    }
    
    func checkMigrations() {
        var config = Realm.Configuration()
        config.schemaVersion = 9
        config.migrationBlock = { migration, oldSchemaVersion in
            // migration logic...
        }
        Realm.Configuration.defaultConfiguration = config
    }
    
    func loadExpenses() throws -> Results<Expense> {
        let realm = try Realm()
        if let user = try getCurrentUser(realm: realm) {
            let forUser = NSPredicate(format: "userId == %@", user.id)
            let expenses = realm.objects(Expense.self).filter(forUser).sorted(byKeyPath: "createdAt")
            return expenses
        }
        
        fatalError("User is not authorized")
    }
    
    func loadExpensesToApprove() throws -> Results<Expense> {
        let realm = try Realm()
        if let user = try getCurrentUser(realm: realm),
            let subordinateIds = user.approverForUserIds {
            let userIds = Array(subordinateIds.map {$0})
            let forUsers = NSPredicate(format: "userId IN %@ AND status == 1", userIds)
            let expenses = realm.objects(Expense.self).filter(forUsers).sorted(byKeyPath: "createdAt")
            return expenses
        }
        
        fatalError("User is not authorized")
    }
    
    func saveExpenses(_ expenses: [Expense]) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(expenses, update: .modified)
        }
    }
    
    func updateExpense(_ updateBlock: @escaping () -> Void) throws {
        let realm = try Realm()
        try realm.write {
            updateBlock()
        }
    }
    
    func addExpense(_ expense: Expense) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(expense)
        }
    }
    
    func deleteExpense(_ expense: Expense) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(expense)
        }
    }
    
    // MARK: Not used
    func onExpensesChanged(_ handler: @escaping () -> Void) throws {
        let realm = try Realm()
        let notificationToken = realm.observe { (notification, realm) in
            handler()
        }
        
        self.addNotificationToken(notificationToken)
    }

    func deleteUsersAndObserveChanges() throws -> Results<User> {
        let realm = try Realm()
        let users = realm.objects(User.self)
        try realm.write {
            realm.delete(users)
        }
        return users
    }
    
    func getCurrentUser(realm: Realm? = nil) throws -> User? {
        let rlm = try realm ?? Realm()
        rlm.refresh()
        let users = rlm.objects(User.self)
        let user = users.first
        return user
    }
    
    func saveCurrentUser(user: User) throws {
        print("saveCurrentUser: \(user)")
        let realm = try Realm()
        let allUsers = realm.objects(User.self)
        try realm.write {
            realm.delete(allUsers)
            realm.add(user, update: .all)
        }
        realm.refresh()
    }
    
    func deleteCurrentUser() throws {
        let realm = try Realm()
        let allUsers = realm.objects(User.self)
        try realm.write {
            realm.delete(allUsers)
        }
    }
    
    func addNotificationToken(_ token: NotificationToken) {
        notificationTokens.append(token)
    }
    
    func invalidateNotificationTokens() {
        self.notificationTokens.forEach { (token) in
            token.invalidate()
            print("Notification token invalidated: \(token)")
        }
        
        self.notificationTokens.removeAll()
    }
    
    func deleteAllData() throws {
        let realm = try Realm()
        try realm.write {
            realm.deleteAll()
        }
    }
}
