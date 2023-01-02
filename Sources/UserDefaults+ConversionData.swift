//
//  UserDefaults+ConversionData.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 02/01/23.
//

import Foundation

@available(iOS 11.3, *)
extension UserDefaults {
    var conversionDataKey: String { "Tealium.RemoteCommands.ConversionData" }
    var conversionData: ConversionData {
        get {
            guard let data = self.data(forKey: conversionDataKey),
                  let conversionData = try? JSONDecoder().decode(ConversionData.self, from: data) else {
                return ConversionData(fineValue: 0)
            }
            return conversionData
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            self.set(data, forKey: conversionDataKey)
        }
    }
}
