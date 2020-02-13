//
//  CGRectTests.swift
//  AccepterTests
//
//  Created by Tomasz Wiśniewski on 12/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import XCTest
@testable import Accepter

class CGRectTests: XCTestCase {
    func testExpand() {
        let rect = CGRect(x: 1, y: 2, width: 9, height: 11).expand(by: 5)
        
        XCTAssertEqual(rect.origin.x, -4)
        XCTAssertEqual(rect.origin.y, -3)
        XCTAssertEqual(rect.size.width, 19)
        XCTAssertEqual(rect.size.height, 21)
    }
}
