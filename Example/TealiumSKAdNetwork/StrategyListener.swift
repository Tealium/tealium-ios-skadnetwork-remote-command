//
//  StrategyListener.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

private let defaultStrategy = "undefined"
class StrategyListener: ObservableObject {
    
    @Published var selectedStrategy = defaultStrategy
    init() {
        self.evaluateData(data: TealiumHelper.shared.tealium!.dataLayer.all)
        TealiumHelper.shared.tealium?.dataLayer.onDataUpdated.subscribe({ data in
            self.evaluateData(data: data)
        })
    }
    
    func evaluateData(data: [String: Any]) {
        if let strategy = data["strategy"] as? String, strategy != self.selectedStrategy {
            DispatchQueue.main.async {
                if self.selectedStrategy != defaultStrategy {
                    self.resetConversionValue()
                }
                self.selectedStrategy = strategy
            }
        }
    }
    
    func resetConversionValue() {
        TealiumHelper.shared.track(title: "reset_conversion_value", data: nil)
    }

}
