//
//  MixedValueStepsStrategyView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct MixedValueStepsStrategyView: View {
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
                   in: 0...7,
                   label: { Text("Value") },
                   minimumValueLabel: { Text("0") },
                   maximumValueLabel: { Text("7") },
                   onEditingChanged: { editing in
                if !editing {
                    TealiumHelper.shared.track(title: "value_change", data: ["application_fine_value": value])
                }
            })
            Text("Journey Step: \(journeyStep)")
            Button {
                if journeyStep < 7 {
                    journeyStep += 1
                    TealiumHelper.shared.track(title: "journey_step", data: ["journey_step": journeyStep])
                }
            } label: {
                Text("Next journey step [\(journeyStep+1)]")
            }.disabled(journeyStep >= 7)
            Section {
                Text("The ConversionValue will be determined by two different strategies. The Value and the Journey Steps.\nYou can specify any number of bits for the value and leave 6-N bit for the journey. \nIn this case we decided to use 3 and 3. So you can put any value like (from 0 to 7) in the Value Strategy, and have steps from 0 to 7 like the Joruney Steps strategy.\nNote that Value and Steps strategies are only conceptually different and are actually implemented in the same way.")
            }
        }.navigationTitle("Mixed Value/Steps Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "mixed_value_steps", expiry: .forever)
            }
    }
}



