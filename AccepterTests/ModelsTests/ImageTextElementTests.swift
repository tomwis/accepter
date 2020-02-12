//
//  ImageTextElementTests.swift
//  AccepterTests
//
//  Created by Tomasz Wiśniewski on 12/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import XCTest
@testable import Accepter

class ImageTextElementTests: XCTestCase {
    let accuracy: CGFloat = 0.000001
    
    func testPropertyXIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.x, 10, accuracy: accuracy)
    }
    
    func testPropertyYIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.y, 8, accuracy: accuracy)
    }
    
    func testPropertyWidthIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.width, 20, accuracy: accuracy)
    }
    
    func testPropertyHeightIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.height, 8, accuracy: accuracy)
    }
    
    func testPropertyTopLeftIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.topLeft.x, 10, accuracy: accuracy)
        XCTAssertEqual(element.topLeft.y, 8, accuracy: accuracy)
    }
    
    func testPropertyTopRightIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.topRight.x, 30, accuracy: accuracy)
        XCTAssertEqual(element.topRight.y, 8, accuracy: accuracy)
    }
    
    func testPropertyBottomLeftIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.bottomLeft.x, 10, accuracy: accuracy)
        XCTAssertEqual(element.bottomLeft.y, 16, accuracy: accuracy)
    }
    
    func testPropertyBottomRightIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.bottomRight.x, 30, accuracy: accuracy)
        XCTAssertEqual(element.bottomRight.y, 16, accuracy: accuracy)
    }
    
    func testPropertyRectIsCorrect() {
        let element = getElement()
        
        XCTAssertEqual(element.rect.origin.x, 10, accuracy: accuracy)
        XCTAssertEqual(element.rect.origin.y, 8, accuracy: accuracy)
        XCTAssertEqual(element.rect.size.width, 20, accuracy: accuracy)
        XCTAssertEqual(element.rect.size.height, 8, accuracy: accuracy)
    }
    
    private func getElement() -> ImageTextElement {
        return ImageTextElement(topLeftPercent: CGPoint(x: 0.1, y: 0.9),
                                topRightPercent: CGPoint(x: 0.3, y: 0.9),
                                bottomLeftPercent: CGPoint(x: 0.1, y: 0.8),
                                bottomRightPercent: CGPoint(x: 0.3, y: 0.8),
                                imageSize: CGSize(width: 100, height: 80),
                                text: "")
    }
}
