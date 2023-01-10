//
//  JourneyStrategyView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct JourneyStrategyView: View {
    @State var journeyStep = 0
    var body: some View {
        List {
            Text("Journey Step: \(journeyStep)")
            Button {
                if journeyStep < 63 {
                    journeyStep += 1
                    TealiumHelper.shared.track(title: "journey_step", data: ["journey_step": journeyStep])
                }
            } label: {
                Text("Next journey step [\(journeyStep+1)]")
            }.disabled(journeyStep >= 63)
            Section {
                Text("The ConversionValue will increase by 1 for each step taken, up to 63 steps. (This is not much different from the Simple Value Strategy)")
            }
        }.navigationTitle("Journey Steps Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "journey", expiry: .forever)
            }
    }
}
