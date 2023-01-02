//
//  SKADNetworkConstants.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 02/01/23.
//

import Foundation
import StoreKit

enum SKADNetworkConstants {
    static let commandId = "conversioncommand"
    static let description = "Conversion Remote Command"
    static let commandName = "command_name"
    static let version = "1.0.0"
    static let seperator: Character = ","

    struct Commands {
        static let registerAppForAttribution = "registerappforattribution"
        static let setConversionBit = "setconversionbit"
        static let resetConversionBit = "resetconversionbit"
        static let setConversionValue = "setconversionvalue"
    }

    struct EventKeys {
        static let fineValue = "fine_value"
        static let coarseValue = "coarse_value"
        static let bitNumber = "bit_number"
        static let lockWindow = "lock_window"

    }
}

public struct ConversionData: Codable {
    public enum CoarseValue: String, Codable {
        case high
        case medium
        case low

        @available(iOS 16.0, *)
        var toSKAdValue: SKAdNetwork.CoarseConversionValue {
            switch self {
            case .high: return .high
            case .medium: return .medium
            case .low: return .low
            }
        }
    }
    internal(set) public var fineValue: Int
    internal(set) public var coarseValue: CoarseValue?
    internal(set) public var lockWindow: Bool = false
}
