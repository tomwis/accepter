// MARK: - Mocks generated from file: Accepter/Protocols/WebRequestService.swift at 2020-02-17 07:35:44 +0000

//
//  WebRequestService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 24/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.

import Cuckoo
@testable import Accepter

import Foundation


 class MockWebRequestService: WebRequestService, Cuckoo.ProtocolMock {
    
     typealias MocksType = WebRequestService
    
     typealias Stubbing = __StubbingProxy_WebRequestService
     typealias Verification = __VerificationProxy_WebRequestService

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: WebRequestService?

     func enableDefaultImplementation(_ stub: WebRequestService) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     var authorizationService: AuthorizationService? {
        get {
            return cuckoo_manager.getter("authorizationService",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.authorizationService)
        }
        
        set {
            cuckoo_manager.setter("authorizationService",
                value: newValue,
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.authorizationService = newValue)
        }
        
    }
    

    

    
    
    
     func get<TResponse>(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable {
        
    return try cuckoo_manager.callThrows("get(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable",
            parameters: (url, completionHandler),
            escapingParameters: (url, completionHandler),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.get(url: url, completionHandler: completionHandler))
        
    }
    
    
    
     func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody: Encodable, TResponse: Decodable {
        
    return try cuckoo_manager.callThrows("post(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody: Encodable, TResponse: Decodable",
            parameters: (url, data, completionHandler),
            escapingParameters: (url, data, completionHandler),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.post(url: url, data: data, completionHandler: completionHandler))
        
    }
    

	 struct __StubbingProxy_WebRequestService: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var authorizationService: Cuckoo.ProtocolToBeStubbedOptionalProperty<MockWebRequestService, AuthorizationService> {
	        return .init(manager: cuckoo_manager, name: "authorizationService")
	    }
	    
	    
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, TResponse>(url: M1, completionHandler: M2) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<(String, (TResponse?) -> Void)> where M1.MatchedType == String, M2.MatchedType == (TResponse?) -> Void, TResponse: Decodable {
	        let matchers: [Cuckoo.ParameterMatcher<(String, (TResponse?) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: completionHandler) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockWebRequestService.self, method: "get(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable", parameterMatchers: matchers))
	    }
	    
	    func post<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, TBody, TResponse>(url: M1, data: M2, completionHandler: M3) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<(String, TBody, (TResponse?) -> Void)> where M1.MatchedType == String, M2.MatchedType == TBody, M3.MatchedType == (TResponse?) -> Void, TBody: Encodable, TResponse: Decodable {
	        let matchers: [Cuckoo.ParameterMatcher<(String, TBody, (TResponse?) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: data) { $0.1 }, wrap(matchable: completionHandler) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockWebRequestService.self, method: "post(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody: Encodable, TResponse: Decodable", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_WebRequestService: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var authorizationService: Cuckoo.VerifyOptionalProperty<AuthorizationService> {
	        return .init(manager: cuckoo_manager, name: "authorizationService", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, TResponse>(url: M1, completionHandler: M2) -> Cuckoo.__DoNotUse<(String, (TResponse?) -> Void), Void> where M1.MatchedType == String, M2.MatchedType == (TResponse?) -> Void, TResponse: Decodable {
	        let matchers: [Cuckoo.ParameterMatcher<(String, (TResponse?) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: completionHandler) { $0.1 }]
	        return cuckoo_manager.verify("get(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func post<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, TBody, TResponse>(url: M1, data: M2, completionHandler: M3) -> Cuckoo.__DoNotUse<(String, TBody, (TResponse?) -> Void), Void> where M1.MatchedType == String, M2.MatchedType == TBody, M3.MatchedType == (TResponse?) -> Void, TBody: Encodable, TResponse: Decodable {
	        let matchers: [Cuckoo.ParameterMatcher<(String, TBody, (TResponse?) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: data) { $0.1 }, wrap(matchable: completionHandler) { $0.2 }]
	        return cuckoo_manager.verify("post(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody: Encodable, TResponse: Decodable", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class WebRequestServiceStub: WebRequestService {
    
    
     var authorizationService: AuthorizationService? {
        get {
            return DefaultValueRegistry.defaultValue(for: (AuthorizationService?).self)
        }
        
        set { }
        
    }
    

    

    
     func get<TResponse>(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody: Encodable, TResponse: Decodable  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: Accepter/Services/AuthorizationService.swift at 2020-02-17 07:35:44 +0000

//
//  AuthorizationService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 22/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.

import Cuckoo
@testable import Accepter

import Foundation
import RealmSwift


 class MockAuthorizationService: AuthorizationService, Cuckoo.ClassMock {
    
     typealias MocksType = AuthorizationService
    
     typealias Stubbing = __StubbingProxy_AuthorizationService
     typealias Verification = __VerificationProxy_AuthorizationService

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: AuthorizationService?

     func enableDefaultImplementation(_ stub: AuthorizationService) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     override var token: Token? {
        get {
            return cuckoo_manager.getter("token",
                superclassCall:
                    
                    super.token
                    ,
                defaultCall: __defaultImplStub!.token)
        }
        
        set {
            cuckoo_manager.setter("token",
                value: newValue,
                superclassCall:
                    
                    super.token = newValue
                    ,
                defaultCall: __defaultImplStub!.token = newValue)
        }
        
    }
    

    

    
    
    
     override func login(login: String, password: String, completionHandler: @escaping (Bool) -> Void) throws {
        
    return try cuckoo_manager.callThrows("login(login: String, password: String, completionHandler: @escaping (Bool) -> Void) throws",
            parameters: (login, password, completionHandler),
            escapingParameters: (login, password, completionHandler),
            superclassCall:
                
                super.login(login: login, password: password, completionHandler: completionHandler)
                ,
            defaultCall: __defaultImplStub!.login(login: login, password: password, completionHandler: completionHandler))
        
    }
    

	 struct __StubbingProxy_AuthorizationService: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var token: Cuckoo.ClassToBeStubbedOptionalProperty<MockAuthorizationService, Token> {
	        return .init(manager: cuckoo_manager, name: "token")
	    }
	    
	    
	    func login<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(login: M1, password: M2, completionHandler: M3) -> Cuckoo.ClassStubNoReturnThrowingFunction<(String, String, (Bool) -> Void)> where M1.MatchedType == String, M2.MatchedType == String, M3.MatchedType == (Bool) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(String, String, (Bool) -> Void)>] = [wrap(matchable: login) { $0.0 }, wrap(matchable: password) { $0.1 }, wrap(matchable: completionHandler) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockAuthorizationService.self, method: "login(login: String, password: String, completionHandler: @escaping (Bool) -> Void) throws", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_AuthorizationService: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var token: Cuckoo.VerifyOptionalProperty<Token> {
	        return .init(manager: cuckoo_manager, name: "token", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func login<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(login: M1, password: M2, completionHandler: M3) -> Cuckoo.__DoNotUse<(String, String, (Bool) -> Void), Void> where M1.MatchedType == String, M2.MatchedType == String, M3.MatchedType == (Bool) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(String, String, (Bool) -> Void)>] = [wrap(matchable: login) { $0.0 }, wrap(matchable: password) { $0.1 }, wrap(matchable: completionHandler) { $0.2 }]
	        return cuckoo_manager.verify("login(login: String, password: String, completionHandler: @escaping (Bool) -> Void) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class AuthorizationServiceStub: AuthorizationService {
    
    
     override var token: Token? {
        get {
            return DefaultValueRegistry.defaultValue(for: (Token?).self)
        }
        
        set { }
        
    }
    

    

    
     override func login(login: String, password: String, completionHandler: @escaping (Bool) -> Void) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: Accepter/Services/LocalStorageService.swift at 2020-02-17 07:35:44 +0000

//
//  LocalStorageService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 21/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.

import Cuckoo
@testable import Accepter

import Foundation
import RealmSwift


 class MockLocalStorageService: LocalStorageService, Cuckoo.ClassMock {
    
     typealias MocksType = LocalStorageService
    
     typealias Stubbing = __StubbingProxy_LocalStorageService
     typealias Verification = __VerificationProxy_LocalStorageService

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: LocalStorageService?

     func enableDefaultImplementation(_ stub: LocalStorageService) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    
    
    
     override var notificationTokens: [NotificationToken] {
        get {
            return cuckoo_manager.getter("notificationTokens",
                superclassCall:
                    
                    super.notificationTokens
                    ,
                defaultCall: __defaultImplStub!.notificationTokens)
        }
        
        set {
            cuckoo_manager.setter("notificationTokens",
                value: newValue,
                superclassCall:
                    
                    super.notificationTokens = newValue
                    ,
                defaultCall: __defaultImplStub!.notificationTokens = newValue)
        }
        
    }
    

    

    
    
    
     override func checkMigrations()  {
        
    return cuckoo_manager.call("checkMigrations()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.checkMigrations()
                ,
            defaultCall: __defaultImplStub!.checkMigrations())
        
    }
    
    
    
     override func loadExpenses() throws -> Results<Expense> {
        
    return try cuckoo_manager.callThrows("loadExpenses() throws -> Results<Expense>",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.loadExpenses()
                ,
            defaultCall: __defaultImplStub!.loadExpenses())
        
    }
    
    
    
     override func loadExpensesToApprove() throws -> Results<Expense> {
        
    return try cuckoo_manager.callThrows("loadExpensesToApprove() throws -> Results<Expense>",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.loadExpensesToApprove()
                ,
            defaultCall: __defaultImplStub!.loadExpensesToApprove())
        
    }
    
    
    
     override func saveExpenses(_ expenses: [Expense]) throws {
        
    return try cuckoo_manager.callThrows("saveExpenses(_: [Expense]) throws",
            parameters: (expenses),
            escapingParameters: (expenses),
            superclassCall:
                
                super.saveExpenses(expenses)
                ,
            defaultCall: __defaultImplStub!.saveExpenses(expenses))
        
    }
    
    
    
     override func updateExpense(_ updateBlock: @escaping () -> Void) throws {
        
    return try cuckoo_manager.callThrows("updateExpense(_: @escaping () -> Void) throws",
            parameters: (updateBlock),
            escapingParameters: (updateBlock),
            superclassCall:
                
                super.updateExpense(updateBlock)
                ,
            defaultCall: __defaultImplStub!.updateExpense(updateBlock))
        
    }
    
    
    
     override func addExpense(_ expense: Expense) throws {
        
    return try cuckoo_manager.callThrows("addExpense(_: Expense) throws",
            parameters: (expense),
            escapingParameters: (expense),
            superclassCall:
                
                super.addExpense(expense)
                ,
            defaultCall: __defaultImplStub!.addExpense(expense))
        
    }
    
    
    
     override func deleteExpense(_ expense: Expense) throws {
        
    return try cuckoo_manager.callThrows("deleteExpense(_: Expense) throws",
            parameters: (expense),
            escapingParameters: (expense),
            superclassCall:
                
                super.deleteExpense(expense)
                ,
            defaultCall: __defaultImplStub!.deleteExpense(expense))
        
    }
    
    
    
     override func onExpensesChanged(_ handler: @escaping () -> Void) throws {
        
    return try cuckoo_manager.callThrows("onExpensesChanged(_: @escaping () -> Void) throws",
            parameters: (handler),
            escapingParameters: (handler),
            superclassCall:
                
                super.onExpensesChanged(handler)
                ,
            defaultCall: __defaultImplStub!.onExpensesChanged(handler))
        
    }
    
    
    
     override func deleteUsersAndObserveChanges() throws -> Results<User> {
        
    return try cuckoo_manager.callThrows("deleteUsersAndObserveChanges() throws -> Results<User>",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.deleteUsersAndObserveChanges()
                ,
            defaultCall: __defaultImplStub!.deleteUsersAndObserveChanges())
        
    }
    
    
    
     override func getCurrentUser(realm: Realm?) throws -> User? {
        
    return try cuckoo_manager.callThrows("getCurrentUser(realm: Realm?) throws -> User?",
            parameters: (realm),
            escapingParameters: (realm),
            superclassCall:
                
                super.getCurrentUser(realm: realm)
                ,
            defaultCall: __defaultImplStub!.getCurrentUser(realm: realm))
        
    }
    
    
    
     override func saveCurrentUser(user: User) throws {
        
    return try cuckoo_manager.callThrows("saveCurrentUser(user: User) throws",
            parameters: (user),
            escapingParameters: (user),
            superclassCall:
                
                super.saveCurrentUser(user: user)
                ,
            defaultCall: __defaultImplStub!.saveCurrentUser(user: user))
        
    }
    
    
    
     override func deleteCurrentUser() throws {
        
    return try cuckoo_manager.callThrows("deleteCurrentUser() throws",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.deleteCurrentUser()
                ,
            defaultCall: __defaultImplStub!.deleteCurrentUser())
        
    }
    
    
    
     override func addNotificationToken(_ token: NotificationToken)  {
        
    return cuckoo_manager.call("addNotificationToken(_: NotificationToken)",
            parameters: (token),
            escapingParameters: (token),
            superclassCall:
                
                super.addNotificationToken(token)
                ,
            defaultCall: __defaultImplStub!.addNotificationToken(token))
        
    }
    
    
    
     override func invalidateNotificationTokens()  {
        
    return cuckoo_manager.call("invalidateNotificationTokens()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.invalidateNotificationTokens()
                ,
            defaultCall: __defaultImplStub!.invalidateNotificationTokens())
        
    }
    
    
    
     override func deleteAllData() throws {
        
    return try cuckoo_manager.callThrows("deleteAllData() throws",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.deleteAllData()
                ,
            defaultCall: __defaultImplStub!.deleteAllData())
        
    }
    

	 struct __StubbingProxy_LocalStorageService: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var notificationTokens: Cuckoo.ClassToBeStubbedProperty<MockLocalStorageService, [NotificationToken]> {
	        return .init(manager: cuckoo_manager, name: "notificationTokens")
	    }
	    
	    
	    func checkMigrations() -> Cuckoo.ClassStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "checkMigrations()", parameterMatchers: matchers))
	    }
	    
	    func loadExpenses() -> Cuckoo.ClassStubThrowingFunction<(), Results<Expense>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "loadExpenses() throws -> Results<Expense>", parameterMatchers: matchers))
	    }
	    
	    func loadExpensesToApprove() -> Cuckoo.ClassStubThrowingFunction<(), Results<Expense>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "loadExpensesToApprove() throws -> Results<Expense>", parameterMatchers: matchers))
	    }
	    
	    func saveExpenses<M1: Cuckoo.Matchable>(_ expenses: M1) -> Cuckoo.ClassStubNoReturnThrowingFunction<([Expense])> where M1.MatchedType == [Expense] {
	        let matchers: [Cuckoo.ParameterMatcher<([Expense])>] = [wrap(matchable: expenses) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "saveExpenses(_: [Expense]) throws", parameterMatchers: matchers))
	    }
	    
	    func updateExpense<M1: Cuckoo.Matchable>(_ updateBlock: M1) -> Cuckoo.ClassStubNoReturnThrowingFunction<(() -> Void)> where M1.MatchedType == () -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(() -> Void)>] = [wrap(matchable: updateBlock) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "updateExpense(_: @escaping () -> Void) throws", parameterMatchers: matchers))
	    }
	    
	    func addExpense<M1: Cuckoo.Matchable>(_ expense: M1) -> Cuckoo.ClassStubNoReturnThrowingFunction<(Expense)> where M1.MatchedType == Expense {
	        let matchers: [Cuckoo.ParameterMatcher<(Expense)>] = [wrap(matchable: expense) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "addExpense(_: Expense) throws", parameterMatchers: matchers))
	    }
	    
	    func deleteExpense<M1: Cuckoo.Matchable>(_ expense: M1) -> Cuckoo.ClassStubNoReturnThrowingFunction<(Expense)> where M1.MatchedType == Expense {
	        let matchers: [Cuckoo.ParameterMatcher<(Expense)>] = [wrap(matchable: expense) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "deleteExpense(_: Expense) throws", parameterMatchers: matchers))
	    }
	    
	    func onExpensesChanged<M1: Cuckoo.Matchable>(_ handler: M1) -> Cuckoo.ClassStubNoReturnThrowingFunction<(() -> Void)> where M1.MatchedType == () -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(() -> Void)>] = [wrap(matchable: handler) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "onExpensesChanged(_: @escaping () -> Void) throws", parameterMatchers: matchers))
	    }
	    
	    func deleteUsersAndObserveChanges() -> Cuckoo.ClassStubThrowingFunction<(), Results<User>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "deleteUsersAndObserveChanges() throws -> Results<User>", parameterMatchers: matchers))
	    }
	    
	    func getCurrentUser<M1: Cuckoo.OptionalMatchable>(realm: M1) -> Cuckoo.ClassStubThrowingFunction<(Realm?), User?> where M1.OptionalMatchedType == Realm {
	        let matchers: [Cuckoo.ParameterMatcher<(Realm?)>] = [wrap(matchable: realm) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "getCurrentUser(realm: Realm?) throws -> User?", parameterMatchers: matchers))
	    }
	    
	    func saveCurrentUser<M1: Cuckoo.Matchable>(user: M1) -> Cuckoo.ClassStubNoReturnThrowingFunction<(User)> where M1.MatchedType == User {
	        let matchers: [Cuckoo.ParameterMatcher<(User)>] = [wrap(matchable: user) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "saveCurrentUser(user: User) throws", parameterMatchers: matchers))
	    }
	    
	    func deleteCurrentUser() -> Cuckoo.ClassStubNoReturnThrowingFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "deleteCurrentUser() throws", parameterMatchers: matchers))
	    }
	    
	    func addNotificationToken<M1: Cuckoo.Matchable>(_ token: M1) -> Cuckoo.ClassStubNoReturnFunction<(NotificationToken)> where M1.MatchedType == NotificationToken {
	        let matchers: [Cuckoo.ParameterMatcher<(NotificationToken)>] = [wrap(matchable: token) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "addNotificationToken(_: NotificationToken)", parameterMatchers: matchers))
	    }
	    
	    func invalidateNotificationTokens() -> Cuckoo.ClassStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "invalidateNotificationTokens()", parameterMatchers: matchers))
	    }
	    
	    func deleteAllData() -> Cuckoo.ClassStubNoReturnThrowingFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLocalStorageService.self, method: "deleteAllData() throws", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_LocalStorageService: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	    
	    var notificationTokens: Cuckoo.VerifyProperty<[NotificationToken]> {
	        return .init(manager: cuckoo_manager, name: "notificationTokens", callMatcher: callMatcher, sourceLocation: sourceLocation)
	    }
	    
	
	    
	    @discardableResult
	    func checkMigrations() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("checkMigrations()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func loadExpenses() -> Cuckoo.__DoNotUse<(), Results<Expense>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("loadExpenses() throws -> Results<Expense>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func loadExpensesToApprove() -> Cuckoo.__DoNotUse<(), Results<Expense>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("loadExpensesToApprove() throws -> Results<Expense>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func saveExpenses<M1: Cuckoo.Matchable>(_ expenses: M1) -> Cuckoo.__DoNotUse<([Expense]), Void> where M1.MatchedType == [Expense] {
	        let matchers: [Cuckoo.ParameterMatcher<([Expense])>] = [wrap(matchable: expenses) { $0 }]
	        return cuckoo_manager.verify("saveExpenses(_: [Expense]) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func updateExpense<M1: Cuckoo.Matchable>(_ updateBlock: M1) -> Cuckoo.__DoNotUse<(() -> Void), Void> where M1.MatchedType == () -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(() -> Void)>] = [wrap(matchable: updateBlock) { $0 }]
	        return cuckoo_manager.verify("updateExpense(_: @escaping () -> Void) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func addExpense<M1: Cuckoo.Matchable>(_ expense: M1) -> Cuckoo.__DoNotUse<(Expense), Void> where M1.MatchedType == Expense {
	        let matchers: [Cuckoo.ParameterMatcher<(Expense)>] = [wrap(matchable: expense) { $0 }]
	        return cuckoo_manager.verify("addExpense(_: Expense) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func deleteExpense<M1: Cuckoo.Matchable>(_ expense: M1) -> Cuckoo.__DoNotUse<(Expense), Void> where M1.MatchedType == Expense {
	        let matchers: [Cuckoo.ParameterMatcher<(Expense)>] = [wrap(matchable: expense) { $0 }]
	        return cuckoo_manager.verify("deleteExpense(_: Expense) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func onExpensesChanged<M1: Cuckoo.Matchable>(_ handler: M1) -> Cuckoo.__DoNotUse<(() -> Void), Void> where M1.MatchedType == () -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(() -> Void)>] = [wrap(matchable: handler) { $0 }]
	        return cuckoo_manager.verify("onExpensesChanged(_: @escaping () -> Void) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func deleteUsersAndObserveChanges() -> Cuckoo.__DoNotUse<(), Results<User>> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("deleteUsersAndObserveChanges() throws -> Results<User>", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func getCurrentUser<M1: Cuckoo.OptionalMatchable>(realm: M1) -> Cuckoo.__DoNotUse<(Realm?), User?> where M1.OptionalMatchedType == Realm {
	        let matchers: [Cuckoo.ParameterMatcher<(Realm?)>] = [wrap(matchable: realm) { $0 }]
	        return cuckoo_manager.verify("getCurrentUser(realm: Realm?) throws -> User?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func saveCurrentUser<M1: Cuckoo.Matchable>(user: M1) -> Cuckoo.__DoNotUse<(User), Void> where M1.MatchedType == User {
	        let matchers: [Cuckoo.ParameterMatcher<(User)>] = [wrap(matchable: user) { $0 }]
	        return cuckoo_manager.verify("saveCurrentUser(user: User) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func deleteCurrentUser() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("deleteCurrentUser() throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func addNotificationToken<M1: Cuckoo.Matchable>(_ token: M1) -> Cuckoo.__DoNotUse<(NotificationToken), Void> where M1.MatchedType == NotificationToken {
	        let matchers: [Cuckoo.ParameterMatcher<(NotificationToken)>] = [wrap(matchable: token) { $0 }]
	        return cuckoo_manager.verify("addNotificationToken(_: NotificationToken)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func invalidateNotificationTokens() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("invalidateNotificationTokens()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func deleteAllData() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("deleteAllData() throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class LocalStorageServiceStub: LocalStorageService {
    
    
     override var notificationTokens: [NotificationToken] {
        get {
            return DefaultValueRegistry.defaultValue(for: ([NotificationToken]).self)
        }
        
        set { }
        
    }
    

    

    
     override func checkMigrations()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func loadExpenses() throws -> Results<Expense>  {
        return DefaultValueRegistry.defaultValue(for: (Results<Expense>).self)
    }
    
     override func loadExpensesToApprove() throws -> Results<Expense>  {
        return DefaultValueRegistry.defaultValue(for: (Results<Expense>).self)
    }
    
     override func saveExpenses(_ expenses: [Expense]) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func updateExpense(_ updateBlock: @escaping () -> Void) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func addExpense(_ expense: Expense) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func deleteExpense(_ expense: Expense) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func onExpensesChanged(_ handler: @escaping () -> Void) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func deleteUsersAndObserveChanges() throws -> Results<User>  {
        return DefaultValueRegistry.defaultValue(for: (Results<User>).self)
    }
    
     override func getCurrentUser(realm: Realm?) throws -> User?  {
        return DefaultValueRegistry.defaultValue(for: (User?).self)
    }
    
     override func saveCurrentUser(user: User) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func deleteCurrentUser() throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func addNotificationToken(_ token: NotificationToken)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func invalidateNotificationTokens()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func deleteAllData() throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}

