//
//  ValueBitLimiterTests.swift
//  TealiumSKAdNetwork_Tests
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import TealiumSKAdNetwork

final class ValueBitLimiterTests: XCTestCase {
    let limiter = ValueBitLimiter()
    var stored = 31 // "11111"
    
    func testLimitLeft0() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 0), stored)
    }
    
    func testLimitLeft1() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 1).bits, "11111")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 1).bits, "111111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 1).bits, "11111")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 1).bits, "111111")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 1).bits, "11111")
    }
    
    func testLimitLeft2() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 2).bits, "1111")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 2).bits, "111111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 2).bits, "101111")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 2).bits, "11111")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 2).bits, "1111")
    }
    
    func testLimitLeft3() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 3).bits, "100111")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 3).bits, "11111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 3).bits, "10111")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 3).bits, "1111")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 3).bits, "111")
    }
    
    func testLimitLeft4() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 4).bits, "10011")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 4).bits, "1111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 4).bits, "1011")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 4).bits, "111")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 4).bits, "11")
    }
    
    func testLimitLeft5() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 5).bits, "1001")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 5).bits, "111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 5).bits, "101")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 5).bits, "11")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 5).bits, "1")
    }
    
    func testLimitLeft6() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromLeftLimitedTo: 6), 4)
        XCTAssertEqual(limiter.setValue(3, on: stored, fromLeftLimitedTo: 6), 3)
        XCTAssertEqual(limiter.setValue(2, on: stored, fromLeftLimitedTo: 6), 2)
        XCTAssertEqual(limiter.setValue(1, on: stored, fromLeftLimitedTo: 6), 1)
        XCTAssertEqual(limiter.setValue(0, on: stored, fromLeftLimitedTo: 6), 0)
    }
    
    func testLimitRight0() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 0), stored)
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 0), stored)
    }
    
    func testLimitRight1() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 1).bits, "11110")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 1).bits, "11111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 1).bits, "11110")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 1).bits, "11111")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 1).bits, "11110")
    }
    
    func testLimitRight2() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 2).bits, "11100")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 2).bits, "11111")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 2).bits, "11110")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 2).bits, "11101")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 2).bits, "11100")
    }
    
    func testLimitRight3() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 3).bits, "11100")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 3).bits, "11011")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 3).bits, "11010")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 3).bits, "11001")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 3).bits, "11000")
    }
    
    func testLimitRight4() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 4).bits, "10100")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 4).bits, "10011")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 4).bits, "10010")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 4).bits, "10001")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 4).bits, "10000")
    }
    
    func testLimitRight5() {
        stored = 63 // "111111"
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 5).bits, "100100")
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 5).bits, "100011")
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 5).bits, "100010")
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 5).bits, "100001")
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 5).bits, "100000")
    }
    
    func testLimitRight6() {
        XCTAssertEqual(limiter.setValue(4, on: stored, fromRightLimitedTo: 6), 4)
        XCTAssertEqual(limiter.setValue(3, on: stored, fromRightLimitedTo: 6), 3)
        XCTAssertEqual(limiter.setValue(2, on: stored, fromRightLimitedTo: 6), 2)
        XCTAssertEqual(limiter.setValue(1, on: stored, fromRightLimitedTo: 6), 1)
        XCTAssertEqual(limiter.setValue(0, on: stored, fromRightLimitedTo: 6), 0)
    }
}

extension Int {
    var bits: String {
        String(self, radix: 2)
    }
}
