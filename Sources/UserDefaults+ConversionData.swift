//
//  UserDefaults+ConversionData.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 02/01/23.
//

import Foundation

@available(iOS 11.3, *)
extension UserDefaults {
    private var key: String { "Tealium.RemoteCommands.fineConversionValue" }
    var fineConversionValue: Int {
        get {
            guard let data = self.data(forKey: key),
                  let conversionData = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return conversionData
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            self.set(data, forKey: key)
        }
    }
}
