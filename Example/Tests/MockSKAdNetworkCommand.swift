//
//  MockSKAdNetworkCommand.swift
//  TealiumSKAdNetwork_Tests
//
//  Created by Enrico Zannini on 02/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
@testable import TealiumSKAdNetwork

class MockSKAdNeworkCommand: SKAdNetworkCommand {
    var conversionData: ConversionData = ConversionData(fineValue: 0)
    var configuration = SKAdNetworkConfiguration(sendHigherValue: false)
    var lockWindow = false
    var postbackConversionValueCalls = 0
    var registerForAttributionCalls = 0
    func initialize(configuration: SKAdNetworkConfiguration) {
        self.configuration = configuration
    }
    func updateConversionData(fineValue: Int, coarseValue: ConversionData.CoarseValue?) {
        conversionData.fineValue = fineValue
        conversionData.coarseValue = coarseValue
    }
    func updatePostbackConversionValue(lockWindow: Bool) {
        self.lockWindow = lockWindow
        postbackConversionValueCalls += 1
    }
    func registerAppForAttribution() {
        registerForAttributionCalls += 1
    }
    func resetConversionData() {
        conversionData = ConversionData(fineValue: 0)
    }
}
