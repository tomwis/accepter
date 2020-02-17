//
//  UserServiceTests.swift
//  AccepterTests
//
//  Created by Tomasz Wiśniewski on 14/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import XCTest
@testable import Accepter
import Cuckoo

class UserServiceTests: XCTestCase {

    func testGetUserDataReturnsNilWhenNoUserIsReturnedFromApi() {
        let sut = UserService(webRequestService: UserServiceWebRequestServiceStub(), localStorageService: LocalStorageServiceStub(authorizationService: AuthorizationServiceStub(webRequestService: WebRequestServiceStub())))
        
        let expectation = XCTestExpectation()
        
        try! sut.getUserData { (user) in
            XCTAssertNil(user)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetUserDataReturnsUserFromLocalStorageIfAvailable() {
        let expectedUser = User()
        expectedUser.id = "id"
        
        let mockLocalStorageService = MockLocalStorageService(authorizationService: AuthorizationServiceStub(webRequestService: WebRequestServiceStub()))
        stub(mockLocalStorageService) { (stub) in
            when(stub.getCurrentUser(realm: any())).thenReturn(expectedUser)
        }
        
        let sut = UserService(webRequestService: UserServiceWebRequestServiceStub(), localStorageService: mockLocalStorageService)
        
        let expectation = XCTestExpectation()
        
        try! sut.getUserData { (actualUser) in
            XCTAssertEqual(actualUser?.id, expectedUser.id)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetUserDataReturnsUserFromApiIfNotAvailableLocally() {
        let expectedUser = User()
        expectedUser.id = "id"
        
        let sut = UserService(webRequestService: UserServiceWebRequestServiceStub(user: expectedUser), localStorageService: LocalStorageServiceStub(authorizationService: AuthorizationServiceStub(webRequestService: WebRequestServiceStub())))
        
        let expectation = XCTestExpectation()
        
        try! sut.getUserData { (actualUser) in
            XCTAssertEqual(actualUser?.id, expectedUser.id)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetUserDataSavesUserFromApiLocally() {
        let expectedUser = User()
        expectedUser.id = "id"
        
        let mockLocalStorageService = MockLocalStorageService(authorizationService: AuthorizationServiceStub(webRequestService: WebRequestServiceStub()))
            .withEnabledSuperclassSpy()
        
        let sut = UserService(webRequestService: UserServiceWebRequestServiceStub(user: expectedUser), localStorageService: mockLocalStorageService)
        
        let expectation = XCTestExpectation()
        
        try! sut.getUserData { (actualUser) in
            verify(mockLocalStorageService).saveCurrentUser(user: any(User.self))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    private class UserServiceWebRequestServiceStub: WebRequestService {
        var authorizationService: AuthorizationService?
        var user: User?
        
        init(user: User? = nil) {
            self.user = user
        }
        
        func get<TResponse>(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse : Decodable {
            completionHandler(user as? TResponse)
        }
        
        func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody : Encodable, TResponse : Decodable {
            
        }
    }
}

