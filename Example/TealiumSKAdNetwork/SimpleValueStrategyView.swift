//
//  SimpleValueStrategyView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct SimpleValueStrategyView: View {
    @State var value = 0
    @State var journeyStep = 0
    var intProxy: Binding<Double>{
        Binding<Double>(get: {
            //returns the score as a Double
            return Double(value)
        }, set: {
            value = Int($0)
        })
    }
    var body: some View {
        List {
            Text("Value: \(value)")
            Slider(value: intProxy,
                   in: 0...63,
                   label: { Text("Value") },
                   minimumValueLabel: { Text("0") },
                   maximumValueLabel: { Text("63") },
                   onEditingChanged: { editing in
                if !editing {
                    TealiumHelper.shared.track(title: "value_change", data: [
                        "application_fine_value": value,
                        "application_coarse_value": (value > 40 ? "high" : value > 20 ? "medium" : "low")])
                }
            })
            Section {
                Text("The ConversionValue will be determined by the specified value.")
            }
        }.navigationTitle("Simple Value Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "simple_value", expiry: .forever)
            }
    }
}
