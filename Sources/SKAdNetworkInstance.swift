//
//  SKAdNetworkInstance.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 02/01/23.
//

import Foundation
import StoreKit

public struct SKAdNetworkConfiguration {
    let sendHigherValue: Bool
}

public protocol SKAdNetworkCommand {
    var conversionData: ConversionData { get }
    func initialize(configuration: SKAdNetworkConfiguration)
    func updateConversionData(fineValue: Int, coarseValue: ConversionData.CoarseValue?)
    func updatePostbackConversionValue(lockWindow: Bool)
    func registerAppForAttribution()
    func resetConversionData()
}

@available(iOS 11.3, *)
class SKAdNetworkInstance: SKAdNetworkCommand {
    public weak var conversionDelegate: SKAdNetworkConversionDelegate?
    let userDefaults: UserDefaults
    private(set) var conversionData: ConversionData
    var configuration = SKAdNetworkConfiguration(sendHigherValue: false)
    init(conversionDelegate: SKAdNetworkConversionDelegate? = nil, userDefaults: UserDefaults? = nil) {
        self.conversionDelegate = conversionDelegate
        let defaults = userDefaults ?? UserDefaults(suiteName: "Tealium.RemoteCommands.SKAdNetwork") ?? .standard
        self.userDefaults = defaults
        conversionData = defaults.conversionData
    }
    
    func initialize(configuration: SKAdNetworkConfiguration) {
        self.configuration = configuration
    }
    
    func shouldUpdateCoarseValue(_ coarseValue: ConversionData.CoarseValue?) -> Bool {
        guard let savedValue = conversionData.coarseValue,
              let coarseValue = coarseValue else { return true }
        return coarseValue > savedValue || !configuration.sendHigherValue
    }
    
    func shouldUpdateFineValue(_ fineValue: Int) -> Bool {
        fineValue >= 0 && fineValue < 64 && // fineValue is in range
        (fineValue > conversionData.fineValue || !configuration.sendHigherValue) // fineValue is higher or higher is not required
    }
    
    func updateConversionData(fineValue: Int, coarseValue: ConversionData.CoarseValue?) {
        if shouldUpdateFineValue(fineValue) {
            conversionData.fineValue = fineValue
        }
        if let coarseValue = coarseValue,
            shouldUpdateCoarseValue(coarseValue) {
            conversionData.coarseValue = coarseValue
        }
    }
    
    func updatePostbackConversionValue(lockWindow: Bool) {
        let conversionData = self.conversionData
        let completion = self.conversionDelegate?.onConversionUpdateCompleted(error:)
        var needsSynchronousCompletion = false
        if #available(iOS 15.4, *) {
            if #available(iOS 16.1, *), let coarseValue = conversionData.coarseValue?.toSKAdValue {
                SKAdNetwork.updatePostbackConversionValue(conversionData.fineValue,
                                                          coarseValue: coarseValue,
                                                          lockWindow: lockWindow,
                                                          completionHandler: completion)
            } else {
                SKAdNetwork.updatePostbackConversionValue(conversionData.fineValue,
                                                          completionHandler: completion)
            }
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(conversionData.fineValue)
            needsSynchronousCompletion = true
        }
        userDefaults.conversionData = conversionData
        conversionDelegate?.onConversionUpdate(conversionData: conversionData, lockWindow: lockWindow)
        if needsSynchronousCompletion {
            completion?(nil)
        }
    }
    
    func registerAppForAttribution() {
        if #unavailable(iOS 14.0) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
        }
    }
    
    /// Sets conversion data to the default values even with the sendHigherValue configuration
    func resetConversionData() {
        conversionData = ConversionData(fineValue: 0)
        userDefaults.conversionData = conversionData
    }
}
