//
//  AppView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 04/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

@main
struct AppView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var helper = TealiumHelper.shared
    @State var sendHigherValue = false
    init() {
        TealiumHelper.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                VStack {
                    if let conversion = helper.conversion {
                        Text("FineValue: \(conversion.fineValue)")
                        Text("CoarseValue: \(conversion.coarseValue?.rawValue ?? "unspecified")")
                    } else {
                        Text("JSON Command is wrognly formatted")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(4)
                .background(Color.blue.opacity(0.1))
                NavigationView {
                    List {
                        
                        NavigationLink("Money Spent", destination: MoneyStrategyView())
                        NavigationLink("Jorney Steps", destination: JourneyStrategyView())
                        NavigationLink("Events Based", destination: EventStrategyView())
                        NavigationLink("Mixed Events/Steps", destination: MixedStrategyView())
                        NavigationLink("Mixed Value/Steps", destination: MixedStrategyView())
                        Toggle("Send Higher Value", isOn: Binding<Bool>.init(get: {
                            self.sendHigherValue
                        }, set: { newValue in
                            helper.track(title: "configure_skadnetwork_command", data: ["application_send_higher_value": newValue])
                            self.sendHigherValue = newValue
                        }))
                        Button {
                            helper.track(title: "reset_conversion_value", data: nil)
                        } label: {
                            Text("Reset Conversion Value")
                        }

                    }.navigationTitle("Choose Conversion Strategy")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

enum ConversionStrategy {
    case moneySpent
    case journeyStep
    case events
    case mixed
}

struct MoneyStrategyView: View {
    @State var moneySpent = 0
    
    func roundedToTens(_ money: Int) -> Int {
        10 * Int(money/10)
    }
    
    var body: some View {
        List {
            Text("Money spent: $\(moneySpent)")
            spendButton(amount: 1)
            spendButton(amount: 2)
            spendButton(amount: 3)
            spendButton(amount: 5)
            spendButton(amount: 8)
            spendButton(amount: 13)
            spendButton(amount: 21)
        }.navigationTitle("Money Spent Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "money", expiry: .untilRestart)
            }
    }
    
    func spendButton(amount: Int) -> some View {
        Button {
            spend(amount)
        } label: {
            Text("Spend $\(amount)")
        }
    }
    
    func spend(_ amount: Int) {
        moneySpent += amount
        TealiumHelper.shared.track(title: "spend_money", data: [
            "money_spent": roundedToTens(moneySpent),
            "spending_type": (moneySpent > 200 ? "premium" : moneySpent > 100 ? "medium" : "low")
        ])
    }
}

struct JourneyStrategyView: View {
    @State var journeyStep = 0
    var body: some View {
        List {
            Text("Jorney Step: \(journeyStep)")
            Button {
                journeyStep += 1
                TealiumHelper.shared.track(title: "journey_step", data: ["journey_step": journeyStep])
            } label: {
                Text("Next journey step")
            }.disabled(journeyStep >= 63)
        }.navigationTitle("Journey Steps Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "journey", expiry: .untilRestart)
            }
    }
}

struct EventStrategyView: View {
    @State var events: [Int] = [0, 0, 0, 0, 0, 0]
    var body: some View {
        List {
            Text("Events/Flags: \(events.reversed().description)")
            ForEach(events.indices, id: \.self) { index in
                Button {
                    events[index] = 1
                    TealiumHelper.shared.track(title: "event\(index)", data: [:])
                } label: {
                    Text("Set Event/Flag \(index)")
                }
            }
        }.navigationTitle("Events Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "events", expiry: .untilRestart)
            }
    }
}

struct MixedStrategyView: View {
    @State var events: [Int] = [0, 0, 0]
    @State var journeyStep = 0
    var body: some View {
        List {
            Text("Events/Flags: \(events.reversed().description)")
            Text("Jorney Step: \(journeyStep)")
            ForEach(events.indices, id: \.self) { index in
                Button {
                    events[index] = 1
                    TealiumHelper.shared.track(title: "event\(index)", data: [:])
                } label: {
                    Text("Set Event/Flag \(index)")
                }
            }
            Button {
                if journeyStep < 8 {
                    
                    let value = TealiumHelper.shared.conversion?.fineValue ?? journeyStep
                    journeyStep += 1
                    TealiumHelper.shared.track(title: "journey_step", data: ["journey_step": value+1])
                }
            } label: {
                Text("Next journey step")
            }.disabled(journeyStep >= 8)
        }.navigationTitle("Events Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "mixed_events_steps", expiry: .untilRestart)
            }
    }
}


