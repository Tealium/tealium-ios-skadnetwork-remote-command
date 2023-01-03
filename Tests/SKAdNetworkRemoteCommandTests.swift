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
    
//    func handleCommand(_ commandId: String, payload: [String: Any]) {
//        switch commandId {
//        case SKADNetworkConstants.Commands.initialize:
//            instance.initialize(configuration: getConfiguration(payload: payload))
//        case SKADNetworkConstants.Commands.setConversionBit:
//            guard let bitNumber = getBitNumber(payload: payload) else { return }
//            updateConversionData(fineValue: instance.conversionData.fineValue | (1 << bitNumber),
//                                 payload: payload)
//        case SKADNetworkConstants.Commands.resetConversionBit:
//            guard let bitNumber = getBitNumber(payload: payload) else { return }
//            updateConversionData(fineValue: instance.conversionData.fineValue & ~(1 << bitNumber),
//                                 payload: payload)
//        case SKADNetworkConstants.Commands.setConversionValue:
//            guard let fineValue = payload[SKADNetworkConstants.EventKeys.fineValue] as? Int else {
//                return
//            }
//            updateConversionData(fineValue: fineValue,
//                                 payload: payload)
//        case SKADNetworkConstants.Commands.resetConversionValue:
//            instance.resetConversionData()
//        case SKADNetworkConstants.Commands.registerAppForAttribution:
//            if #unavailable(iOS 14.0) {
//                instance.registerAppForAttribution()
//            }
//        default:
//            break
//        }
//    }
    
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
