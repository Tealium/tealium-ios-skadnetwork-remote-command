//
//  SKAdNetworkRemoteCommandTests.swift
//  TealiumSKAdNetwork_Tests
//
//  Created by Enrico Zannini on 02/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import TealiumSKAdNetwork

@available(iOS 11.3, *)
final class SKAdNetworkRemoteCommandTests: XCTestCase {
    let command = SKAdNetworkRemoteCommand(type: .webview, delegate: nil)
    
    func testGetBitNumber() {
        let payload1: [String: Any] = ["bit_number": 0]
        XCTAssertNotNil(command.getBitNumber(payload: payload1))
        let payload2: [String: Any] = ["bit_number": 5]
        XCTAssertNotNil(command.getBitNumber(payload: payload2))
        let payload3: [String: Any] = ["bit_number": 6]
        XCTAssertNil(command.getBitNumber(payload: payload3), "bit out of bounds")
    }
    
    func testGetConfiguration() {
        let payload1: [String: Any] = ["send_higher_value": true]
        XCTAssertTrue(command.getConfiguration(payload: payload1).sendHigherValue)
        let payload2: [String: Any] = ["send_higher_value": false]
        XCTAssertFalse(command.getConfiguration(payload: payload2).sendHigherValue)
    }

    func testGetLockWindow() {
        let payload1: [String: Any] = ["lock_window": true]
        XCTAssertTrue(command.getLockWindow(payload: payload1))
        let payload2: [String: Any] = ["lock_window": false]
        XCTAssertFalse(command.getLockWindow(payload: payload2))
    }
    
    func testGetCoarseValue() {
        let payload1: [String: Any] = ["coarse_value": "low"]
        XCTAssertEqual(command.getCoarseValue(payload: payload1), .low)
        let payload2: [String: Any] = ["coarse_value": "medium"]
        XCTAssertEqual(command.getCoarseValue(payload: payload2), .medium)
        let payload3: [String: Any] = ["coarse_value": "high"]
        XCTAssertEqual(command.getCoarseValue(payload: payload3), .high)
    }
}
