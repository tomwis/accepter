//
//  DocumentAnalysisServiceTests.swift
//  AccepterTests
//
//  Created by Tomasz Wiśniewski on 12/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import XCTest
@testable import Accepter

class DocumentAnalysisServiceTests: XCTestCase {
    func testAddRegion() {
        let sut = DocumentAnalysisService()
        sut.addRegion((CGRect(), ""))
        
        XCTAssertEqual(sut.imageTextElements.count, 1)
    }
    
    func testRegionTextIsInterpretedAsNumber() {
        let sut = DocumentAnalysisService()
        sut.addRegion((CGRect(), "12"))
        
        XCTAssertEqual(sut.numberElements.count, 1)
        XCTAssertEqual(sut.textElements.count, 0)
    }
    
    func testRegionTextIsNotInterpretedAsNumber() {
        let sut = DocumentAnalysisService()
        sut.addRegion((CGRect(), "a"))
        
        XCTAssertEqual(sut.numberElements.count, 0)
        XCTAssertEqual(sut.textElements.count, 1)
    }
    
    func testCollectionsAreInitializedFromRegions() {
        let regions = [
            (CGRect(), "1"),
            (CGRect(), "2"),
            (CGRect(), "a"),
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize())
        
        XCTAssertEqual(sut.imageTextElements.count, 3)
        XCTAssertEqual(sut.numberElements.count, 2)
        XCTAssertEqual(sut.textElements.count, 1)
    }
    
    func testCollectionsAreInitializedFromImageTextElements() {
        let elements = [
            ImageTextElement(textRect: CGRect(), imageSize: CGSize(), text: "1"),
            ImageTextElement(textRect: CGRect(), imageSize: CGSize(), text: "a"),
            ImageTextElement(textRect: CGRect(), imageSize: CGSize(), text: "b")
        ]
        let sut = DocumentAnalysisService(imageTextElements: elements)
        
        XCTAssertEqual(sut.imageTextElements.count, 3)
        XCTAssertEqual(sut.numberElements.count, 1)
        XCTAssertEqual(sut.textElements.count, 2)
    }
    
    func testGetDataForSavingReturnsAllElements() {
        let sut = DocumentAnalysisService()
        sut.addRegion((CGRect(), ""))
        sut.addRegion((CGRect(), ""))
        
        let items = sut.getDataForSaving()
        
        XCTAssertEqual(items.count, 2)
    }
    
    func testGetValueForPointReturnsNilWhenNoValueFound() {
        let sut = DocumentAnalysisService()
        sut.addRegion((CGRect(), ""))
        
        let result = sut.getValue(for: CGPoint(x: 10, y: 15))
        
        XCTAssertNil(result)
    }
    
    func testGetValueForPointReturnsStringWhenRectForPointFound() {
        let expected = "result string"
        // CGRect unit for origin and size is percentage of image size on which the text was recognized
        // It's exactly as we receive it from vision kit, so 'y' is reversed
        let region = (CGRect(x: 0.1, y: 0.9, width: 0.2, height: 0.2), expected)
        let sut = DocumentAnalysisService(regions: [region], imageSize: CGSize(width: 100, height: 100))
        
        let actual = sut.getValue(for: CGPoint(x: 10, y: 15))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testGetValueForPointExpandsRectOriginForEasierTapping() {
        let expected = "result string"
        let region = (CGRect(x: 0.2, y: 0.75, width: 0.2, height: 0.2), expected)
        let sut = DocumentAnalysisService(regions: [region], imageSize: CGSize(width: 100, height: 100))
        
        // Tapping point is outside of available rect by 10 px
        let actual = sut.getValue(for: CGPoint(x: 10, y: 15))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testGetValueForPointExpandsRectSizeForEasierTapping() {
        let expected = "result string"
        let region = (CGRect(x: 0.2, y: 0.75, width: 0.2, height: 0.2), expected)
        let sut = DocumentAnalysisService(regions: [region], imageSize: CGSize(width: 100, height: 100))
        
        // Tapping point is outside of available rect by 9 px
        // Rect size is expanded by 10 px, the same as origin
        // But contains method of CGRect that we use inside getValue is exclusive for size and inclusive for origin
        let actual = sut.getValue(for: CGPoint(x: 49, y: 54))
        
        XCTAssertEqual(actual, expected)
    }
    
    func testGetPotentialMaxValueItemReturnsNilIfListIsEmpty() {
        let sut = DocumentAnalysisService()
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertNil(result)
    }
    
    func testGetPotentialMaxValueItemReturnsOnlyNumberValue() {
        let sut = DocumentAnalysisService()
        sut.addRegion((CGRect(), "a"))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertNil(result)
    }
    
    func testGetPotentialMaxValueItemReturnsMaxValue() {
        let regions = [
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "1")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "3")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "2"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertEqual(result?.numberValue, 3)
    }
    
    func testGetPotentialMaxValueItemReturnsMaxValueFromLastLineOnly() {
        let regions = [
            ((CGRect(x: 0, y: 0.2, width: 1, height: 0.1), "1")),
            ((CGRect(x: 0, y: 0.4, width: 1, height: 0.1), "3")), // 3 is closer to the top edge in the image than other numbers and it's rect ends before other's numbers rects start
            ((CGRect(x: 0, y: 0.2, width: 1, height: 0.1), "2"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertEqual(result?.numberValue, 2)
    }
    
    func testGetPotentialMaxValueItemUsesOnlyDecimalNumbersIfAvailableTestDecimalPointDot() {
        let regions = [
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "1.0")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "3")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "2.0"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertEqual(result?.numberValue, 2)
    }
    
    func testGetPotentialMaxValueItemUsesOnlyDecimalNumbersWithDotsIfAvailableTestDecimalPointComma() {
        let regions = [
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "1,0")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "3")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "2,0"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertEqual(result?.numberValue, 2)
    }
    
    func testGetPotentialMaxValueItemUsesOnlyNumbersWithIntegerPartShorterThanLimit() {
        let range = 0..<Constants.DocumentAnalysisAmountMaxIntegerPartDigits
        let number = range.map { _ in "1" }.joined()
        let regions = [
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "1.0")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), number)),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "2.0"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertEqual(result?.numberValue, 2)
    }
    
    func testGetPotentialMaxValueItemUsesOnlyNumbersWithIntegerPartShorterThanLimitEvenWhenFractionalPartMakesNumberLonger() {
        let range = 0..<(Constants.DocumentAnalysisAmountMaxIntegerPartDigits - 1)
        var number = range.map { _ in "1" }.joined()
        number += ".1"
        let regions = [
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "1.0")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), number)),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "2.0"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValueItem()
        
        XCTAssertEqual(result?.numberValue, Double(number))
    }
    
    func testGetPotentialMaxValue() {
        let regions = [
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "1")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "3")),
            ((CGRect(x: 0, y: 0, width: 1, height: 1), "2"))
        ]
        let sut = DocumentAnalysisService(regions: regions, imageSize: CGSize(width: 100, height: 100))
        
        let result = sut.getPotentialMaxValue()
        
        XCTAssertEqual(result, 3)
    }
}
