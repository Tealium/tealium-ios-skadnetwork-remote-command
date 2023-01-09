//
//  EventStrategyView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct EventStrategyView: View {
    @State var events: [Int] = [0, 0, 0, 0, 0, 0]
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
            Section {
                Text("The ConversionValue will be the decimal number represented by the 6 bits. Everytime an event happens, the related bit rises, and therefore the decimal representation gets updated. This way you can represent up to 6 events.")
            }
        }.navigationTitle("Events Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "events", expiry: .forever)
            }
    }
}
