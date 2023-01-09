//
//  MixedEventsStepsStrategyView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct MixedEventsStepsStrategyView: View {
    @State var events: [Int] = [0, 0, 0]
    @State var journeyStep = 0
    var body: some View {
        List {
            Text("Events/Flags: \(events.reversed().description)")
            ForEach(events.indices, id: \.self) { index in
                if events[index] == 1 {
                    Button {
                        events[index] = 0
                        TealiumHelper.shared.track(title: "reset_event\(index)", data: [:])
                    } label: {
                        Text("Reset Event/Flag \(index)")
                    }
                } else {
                    Button {
                        events[index] = 1
                        TealiumHelper.shared.track(title: "event\(index)", data: [:])
                    } label: {
                        Text("Set Event/Flag \(index)")
                    }
                }
            }
            Text("Jorney Step: \(journeyStep)")
            Button {
                if journeyStep < 7 {
                    journeyStep += 1
                    TealiumHelper.shared.track(title: "journey_step", data: ["journey_step": journeyStep])
                }
            } label: {
                Text("Next journey step [\(journeyStep+1)]")
            }.disabled(journeyStep >= 7)
            Section {
                Text("The ConversionValue will be determined by two different strategies. The Events and the Journey Steps.\nYou can specify any number of bits for the event and leave 6-N bit for the journey. \nIn this case we decided to use 3 and 3. So you can raise bits 3-4-5 like the Events Strategy, and have steps from 0 to 7 like the Joruney Steps strategy.")
            }
        }.navigationTitle("Mixed Events/Steps Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "mixed_events_steps", expiry: .forever)
            }
    }
}
