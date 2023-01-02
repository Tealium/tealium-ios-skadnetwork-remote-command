//
//  SKAdNetworkRemoteCommand.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 02/01/23.
//

import StoreKit
import TealiumSwift


public protocol ConversionDelegate: AnyObject {
    func onConversionUpdate(conversionData: ConversionData)
    func onConversionUpdateCompleted(error: Error?)
}

@available(iOS 11.3, *)
public class SKAdNetworkRemoteCommand: RemoteCommand {
    override public var version: String? { SKADNetworkConstants.version }
    public weak var conversionDelegate: ConversionDelegate?
    let userDefaults: UserDefaults
    var fineValue = 0
    public init(type: RemoteCommandType, delegate: ConversionDelegate?) {
        conversionDelegate = delegate
        let defaults = UserDefaults(suiteName: "Tealium.RemoteCommands.SKAdNetwork") ?? .standard
        self.userDefaults = defaults
        fineValue = defaults.fineConversionValue
        weak var weakSelf: SKAdNetworkRemoteCommand?
        super.init(commandId: SKADNetworkConstants.commandId, description: SKADNetworkConstants.description, type: type) { response in
            print(response)
            guard let self = weakSelf,
                  let payload = response.payload else {
                return
            }
            self.handleCompletion(payload: payload)
        }
        weakSelf = self
    }

    func handleCompletion(payload: [String: Any]) {
        guard let commandIdString = payload[SKADNetworkConstants.commandName] as? String else {
            return
        }
        let commands = commandIdString.split(separator: SKADNetworkConstants.seperator)
        guard commands.count > 0 else { return }
        var conversionData = ConversionData(fineValue: fineValue)
        commands.forEach { command in
            handleCommand(String(command), payload: payload, conversionData: &conversionData)
        }
        storeConversionData()
        updatePostbackConversionValue(conversionData: conversionData)
        conversionDelegate?.onConversionUpdate(conversionData: conversionData)
    }

    func updateConversionData(_ conversionData: inout ConversionData, fineValue: Int, payload: [String: Any]) {
        conversionData.fineValue = fineValue
        if let coarseValueString = payload[SKADNetworkConstants.EventKeys.coarseValue] as? String,
              let coarseValue = ConversionData.CoarseValue(rawValue: coarseValueString) {
            conversionData.coarseValue = coarseValue
        }
        if let lockWindow = payload[SKADNetworkConstants.EventKeys.lockWindow] as? Bool {
            conversionData.lockWindow = lockWindow
        }
    }

    func handleCommand(_ commandId: String, payload: [String: Any], conversionData: inout ConversionData) {
        switch commandId {
        case SKADNetworkConstants.Commands.setConversionBit:
            guard let bitNumber = getBitNumber(payload: payload) else { return }
            updateConversionData(&conversionData,
                                 fineValue: conversionData.fineValue | (1 << bitNumber),
                                 payload: payload)
        case SKADNetworkConstants.Commands.resetConversionBit:
            guard let bitNumber = getBitNumber(payload: payload) else { return }
            updateConversionData(&conversionData,
                                 fineValue: conversionData.fineValue & ~(1 << bitNumber),
                                 payload: payload)
        case SKADNetworkConstants.Commands.setConversionValue:
            guard let fineValue = payload[SKADNetworkConstants.EventKeys.fineValue] as? Int,
                  fineValue >= 0, fineValue < 64 else {
                return
            }
            updateConversionData(&conversionData,
                                 fineValue: fineValue,
                                 payload: payload)
        case SKADNetworkConstants.Commands.registerAppForAttribution:
            if #unavailable(iOS 14.0) {
                SKAdNetwork.registerAppForAdNetworkAttribution()
            }
        default:
            break
        }
    }

    func getBitNumber(payload: [String: Any]) -> Int? {
        guard let bitNumber = payload[SKADNetworkConstants.EventKeys.bitNumber] as? Int,
            bitNumber >= 0, bitNumber < 6 else {
            return nil
        }
        return bitNumber
    }

    func updatePostbackConversionValue(conversionData: ConversionData) {
        if #available(iOS 15.4, *) {
            let completion = self.conversionDelegate?.onConversionUpdateCompleted(error:)
            if #available(iOS 16.1, *), let coarseValue = conversionData.coarseValue?.toSKAdValue {
                    SKAdNetwork.updatePostbackConversionValue(conversionData.fineValue,
                                                              coarseValue: coarseValue,
                                                              lockWindow: conversionData.lockWindow,
                                                              completionHandler: completion)
            } else {
                SKAdNetwork.updatePostbackConversionValue(conversionData.fineValue, completionHandler: completion)
            }
        } else if #available(iOS 14.0, *) {
            SKAdNetwork.updateConversionValue(conversionData.fineValue)
        }
    }

    func storeConversionData() {
        userDefaults.fineConversionValue = fineValue
    }
}
