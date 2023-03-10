//
//  SKAdNetworkRemoteCommand.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 02/01/23.
//

#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
import TealiumRemoteCommands
#endif

public protocol SKAdNetworkConversionDelegate: AnyObject {
    func onConversionUpdate(conversionData: ConversionData, lockWindow: Bool)
    func onConversionUpdateCompleted(error: Error?)
}

@available(iOS 11.3, *)
public class SKAdNetworkRemoteCommand: RemoteCommand {
    override public var version: String? { SKADNetworkConstants.version }
    let instance: SKAdNetworkCommand
    let limiter = ValueBitLimiter()
    public var conversionData: ConversionData {
        instance.conversionData
    }
    public init(instance: SKAdNetworkCommand? = nil, type: RemoteCommandType, delegate: SKAdNetworkConversionDelegate?) {
        self.instance = instance ?? SKAdNetworkInstance(conversionDelegate: delegate)
        weak var weakSelf: SKAdNetworkRemoteCommand?
        super.init(commandId: SKADNetworkConstants.commandId, description: SKADNetworkConstants.description, type: type) { response in
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
        commands.forEach { command in
            handleCommand(String(command), payload: payload)
        }
        instance.updatePostbackConversionValue(lockWindow: getLockWindow(payload: payload))
    }
    
    func handleCommand(_ commandId: String, payload: [String: Any]) {
        switch commandId {
        case SKADNetworkConstants.Commands.initialize:
            instance.initialize(configuration: getConfiguration(payload: payload))
        case SKADNetworkConstants.Commands.setConversionBit:
            guard let bitNumber = getBitNumber(payload: payload) else { return }
            updateConversionData(fineValue: conversionData.fineValue | (1 << bitNumber),
                                 payload: payload)
        case SKADNetworkConstants.Commands.resetConversionBit:
            guard let bitNumber = getBitNumber(payload: payload) else { return }
            updateConversionData(fineValue: conversionData.fineValue & ~(1 << bitNumber),
                                 payload: payload)
        case SKADNetworkConstants.Commands.setConversionValue:
            guard var fineValue = payload[SKADNetworkConstants.EventKeys.fineValue] as? Int else {
                return
            }
            if let sideLimit = getSideLimit(payload: payload) {
                fineValue = limiter.setValue(fineValue,
                                             on: conversionData.fineValue,
                                             fromSideLimit: sideLimit)
            }
            updateConversionData(fineValue: fineValue,
                                 payload: payload)
        case SKADNetworkConstants.Commands.resetConversionValue:
            instance.resetConversionData()
        case SKADNetworkConstants.Commands.registerAppForAttribution:
            instance.registerAppForAttribution()
        default:
            break
        }
    }
    
    func updateConversionData(fineValue: Int, payload: [String: Any]) {
        instance.updateConversionData(fineValue: fineValue,
                                      coarseValue: getCoarseValue(payload: payload))
    }
    
    func getBitNumber(payload: [String: Any]) -> Int? {
        guard let bitNumber = payload[SKADNetworkConstants.EventKeys.bitNumber] as? Int,
              bitNumber >= 0, bitNumber < 6 else {
            return nil
        }
        return bitNumber
    }
    
    func getConfiguration(payload: [String: Any]) -> SKAdNetworkConfiguration {
        SKAdNetworkConfiguration(sendHigherValue: payload[SKADNetworkConstants.EventKeys.sendHigherValue] as? Bool ?? false)
    }
    
    func getLockWindow(payload: [String: Any]) -> Bool {
        payload[SKADNetworkConstants.EventKeys.lockWindow] as? Bool ?? false
    }
    
    func getCoarseValue(payload: [String: Any]) -> ConversionData.CoarseValue? {
        guard let coarseValueString = payload[SKADNetworkConstants.EventKeys.coarseValue] as? String else {
            return nil
        }
        return ConversionData.CoarseValue(rawValue: coarseValueString)
    }
    
    func getSideLimit(payload: [String: Any]) -> ValueBitLimiter.SideLimit? {
        if let leftLimit = payload[SKADNetworkConstants.EventKeys.limitToHighestNBits] as? Int {
            return .left(leftLimit)
        } else if let rightLimit = payload[SKADNetworkConstants.EventKeys.limitToLowestNBits] as? Int {
            return .right(rightLimit)
        }
        return nil
    }
    
}
