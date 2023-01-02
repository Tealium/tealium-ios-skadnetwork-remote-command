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
        static let initialize = "initialize"
        static let registerAppForAttribution = "registerappforattribution"
        static let setConversionBit = "setconversionbit"
        static let resetConversionBit = "resetconversionbit"
        static let setConversionValue = "setconversionvalue"
        static let resetConversionValue = "resetconversionvalue"
    }

    struct EventKeys {
        static let fineValue = "fine_value"
        static let coarseValue = "coarse_value"
        static let bitNumber = "bit_number"
        static let lockWindow = "lock_window"
        static let sendHigherValue = "send_higher_value"

    }
}

public struct ConversionData: Codable, Equatable {
    public enum CoarseValue: String, Codable, Comparable {
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
        private var intValue: Int {
            switch self {
            case .high: return 2
            case .medium: return 1
            case .low: return 0
            }
        }
        public static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.intValue < rhs.intValue
        }
        public static func >(lhs: Self, rhs: Self) -> Bool {
            lhs.intValue > rhs.intValue
        }
        public static func >=(lhs: Self, rhs: Self) -> Bool {
            lhs.intValue >= rhs.intValue
        }
        public static func <=(lhs: Self, rhs: Self) -> Bool {
            lhs.intValue <= rhs.intValue
        }
        public static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.intValue == rhs.intValue
        }
    }
    internal(set) public var fineValue: Int
    internal(set) public var coarseValue: CoarseValue?
}
