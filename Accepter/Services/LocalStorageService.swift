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
        let users = realm.objects(User.self)
        print("loadExpenses - all users: \(users)")
        if let user = try getCurrentUser(realm: realm) {
            let forUser = NSPredicate(format: "userId == %@", user.id)
            let expenses = realm.objects(Expense.self).filter(forUser).sorted(byKeyPath: "createdAt")
            return expenses
        }
        
        fatalError("User is not authorized")
    }
    
    func loadExpensesToApprove() throws -> Results<Expense> {
        let realm = try Realm()
        if let user = try getCurrentUser(realm: realm) {
            let userIds = Array(user.approverForUserIds.map {$0})
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
    
//    func initUsers() throws {
//        let realm = try Realm()
//
//        guard realm.objects(User.self).count == 0 else { return }
//
//        try! realm.write {
//            let user1 = User(name: "Manager", login: "user1", email: "user1@company.com")
//            let user2 = User(name: "Normal user", login: "user2", email: "user2@company.com", approver: user1)
//            user1.approverForUsers.append(user2)
//            realm.add(user1)
//            realm.add(user2)
//        }
//    }

    func deleteUsersAndObserveChanges() throws -> Results<User> {
        let realm = try Realm()
        let users = realm.objects(User.self)
        try realm.write {
            realm.delete(users)
        }
        return users
    }
    
    func getCurrentUser(realm: Realm? = nil) throws -> User? {
        print("getCurrentUser")
//        let rlm = try realm ?? Realm()
        let rlm = try Realm()
        let users = rlm.objects(User.self)
        print("getCurrentUser - all users: \(users)")
        let user = users.first
        print("getCurrentUser - user: \(user)")
        return user
    }
    
    func saveCurrentUser(user: User, completionHandler: () -> Void) throws {
        print("saveCurrentUser: \(user)")
        let realm = try Realm()
        let allUsers = realm.objects(User.self)
        print("saveCurrentUser - get all: \(allUsers)")
        realm.beginWrite()
//        try realm.write {
            print("saveCurrentUser - delete all: \(allUsers)")
            realm.delete(allUsers)
            let allUsers2 = realm.objects(User.self)
            print("saveCurrentUser - get all 2: \(allUsers2)")
            print("saveCurrentUser - add: \(user)")
            realm.add(user, update: .all)
            print("saveCurrentUser - added: \(user)")
//        }
        try realm.commitWrite()
        completionHandler()
        let allUsers3 = realm.objects(User.self)
        print("saveCurrentUser - get all 3: \(allUsers3)")
    }
    
    func deleteCurrentUser() throws {
        let realm = try Realm()
        let allUsers = realm.objects(User.self)
        print("deleteCurrentUser - all users: \(allUsers)")
        try realm.write {
            realm.delete(allUsers)
            let allUsers2 = realm.objects(User.self)
            print("deleteCurrentUser - after deleted: \(allUsers2)")
        }
        let allUsers3 = realm.objects(User.self)
        print("deleteCurrentUser - after deleted 2: \(allUsers3)")
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
}
