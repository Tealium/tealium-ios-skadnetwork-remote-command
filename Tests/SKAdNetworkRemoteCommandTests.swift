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
    let mockInstance = MockSKAdNeworkCommand()
    lazy var command = SKAdNetworkRemoteCommand(instance: mockInstance, type: .webview, delegate: nil)
    
    func testInitialize() {
        let payload: [String: Any] = [
            "command_name": "initialize",
            "send_higher_value": true
        ]
        command.handleCompletion(payload: payload)
        XCTAssertTrue(mockInstance.configuration.sendHigherValue)
        XCTAssertEqual(mockInstance.postbackConversionValueCalls, 1)
    }
    
    func testSetResetConversionBit() {
        let payload: [String: Any] = [
            "command_name": "setconversionbit",
            "bit_number": 2,
            "coarse_value": "medium"
        ]
        command.handleCompletion(payload: payload)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 4)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .medium)
        let payload2: [String: Any] = [
            "command_name": "setconversionbit",
            "bit_number": 3,
            "coarse_value": "high"
        ]
        command.handleCompletion(payload: payload2)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 12)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .high)
        let payload3: [String: Any] = [
            "command_name": "resetconversionbit",
            "bit_number": 2,
            "coarse_value": "low"
        ]
        command.handleCompletion(payload: payload3)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 8)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .low)
        XCTAssertEqual(mockInstance.postbackConversionValueCalls, 3)
    }
    
    func testSetResetConversionValue() {
        let payload: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 2,
            "coarse_value": "medium"
        ]
        command.handleCompletion(payload: payload)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 2)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .medium)
        let payload2: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 3,
            "coarse_value": "high"
        ]
        command.handleCompletion(payload: payload2)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 3)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .high)
        let payload3: [String: Any] = [
            "command_name": "resetconversionvalue"
        ]
        command.handleCompletion(payload: payload3)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 0)
        XCTAssertNil(mockInstance.conversionData.coarseValue)
        XCTAssertEqual(mockInstance.postbackConversionValueCalls, 3)
    }
    
    func testSetConversionValueLimited() {
        let payload: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 2,
            "coarse_value": "medium",
            "limit_to_highest_n_bits": 3
        ]
        command.handleCompletion(payload: payload)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 16)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .medium)
        mockInstance.resetConversionData()
        let payload2: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 2,
            "coarse_value": "high",
            "limit_to_highest_n_bits": 2
        ]
        command.handleCompletion(payload: payload2)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 32)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .high)
        mockInstance.resetConversionData()
        let payload3: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 9,
            "coarse_value": "medium",
            "limit_to_lowest_n_bits": 3
        ]
        command.handleCompletion(payload: payload3)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 1)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .medium)
        mockInstance.resetConversionData()
        let payload4: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 3,
            "coarse_value": "high",
            "limit_to_lowest_n_bits": 2
        ]
        command.handleCompletion(payload: payload4)
        XCTAssertEqual(mockInstance.conversionData.fineValue, 3)
        XCTAssertEqual(mockInstance.conversionData.coarseValue, .high)
    }
    
    func testLockWindow() {
        let payload: [String: Any] = [
            "command_name": "setconversionvalue",
            "fine_value": 5,
            "coarse_value": "medium",
            "lock_window": true
        ]
        command.handleCompletion(payload: payload)
        XCTAssertEqual(mockInstance.postbackConversionValueCalls, 1)
        XCTAssertTrue(mockInstance.lockWindow)
    }
    
    func testRegisterAppForAttribution() {
        let payload: [String: Any] = [
            "command_name": "registerappforattribution",
        ]
        command.handleCompletion(payload: payload)
        XCTAssertEqual(mockInstance.registerForAttributionCalls, 1)
        XCTAssertEqual(mockInstance.postbackConversionValueCalls, 1)
    }
    
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
    
    func testGetLowestSideLimit() {
        let payload1: [String: Any] = ["limit_to_lowest_n_bits": 2]
        XCTAssertEqual(command.getSideLimit(payload: payload1), .right(2))
        let payload2: [String: Any] = ["limit_to_lowest_n_bits": 4]
        XCTAssertEqual(command.getSideLimit(payload: payload2), .right(4))
    }
    
    func testGetHighestSideLimit() {
        let payload1: [String: Any] = ["limit_to_highest_n_bits": 2]
        XCTAssertEqual(command.getSideLimit(payload: payload1), .left(2))
        let payload2: [String: Any] = ["limit_to_highest_n_bits": 4]
        XCTAssertEqual(command.getSideLimit(payload: payload2), .left(4))
    }
}

extension ValueBitLimiter.SideLimit: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs,rhs) {
        case (.left(let leftValue), .left(let rightValue)):
            return leftValue == rightValue
        case (.right(let leftValue), .right(let rightValue)):
            return leftValue == rightValue
        default:
            return false
        }
    }
}
