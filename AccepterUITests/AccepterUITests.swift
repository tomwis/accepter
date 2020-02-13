//
//  AccepterUITests.swift
//  AccepterUITests
//
//  Created by Tomasz Wiśniewski on 13/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import XCTest

class AccepterUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    override func tearDown() {
        
    }

    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testLogin() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Login"].tap()
        let mySummaryStaticText = app.navigationBars["My Summary"].staticTexts["My Summary"]
        
        XCTAssert(mySummaryStaticText.exists)
    }
    
    func testLogout() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Login"].tap()
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Log out"].tap()
        
        XCTAssert(app.buttons["Login"].exists)
    }
    
    func testAddingNewExpense() {
        
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Login"].tap()
        app.tabBars.buttons["New Expense"].tap()
        let expenseTitle = "Expense Title 1"
        
        // Testing out accessing elements with accessibilityIdentifier
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["TitleField"].tap()
        elementsQuery.textFields["TitleField"].typeText(expenseTitle)
        
        elementsQuery.textFields["CategoryField"].tap()
        elementsQuery.textFields["CategoryField"].typeText("Category")
        
        elementsQuery.textFields["AmountField"].tap()
        elementsQuery.textFields["AmountField"].typeText("123")
        
        elementsQuery.buttons["SaveDraftButton"].tap()
        
        XCTAssert(app.tables.staticTexts[expenseTitle].exists)        
    }
    
    func testDontSendToApprovalNewExpenseWhenTitleIsEmpty() {
        
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Login"].tap()
        app.tabBars.buttons["New Expense"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        
        elementsQuery.textFields["CategoryField"].tap()
        elementsQuery.textFields["CategoryField"].typeText("Category")
        
        elementsQuery.textFields["AmountField"].tap()
        elementsQuery.textFields["AmountField"].typeText("123")
        
        elementsQuery.buttons["Send to Approval"].tap()
        
        XCTAssert(elementsQuery.staticTexts["TitleFieldError"].exists)        
    }
}
