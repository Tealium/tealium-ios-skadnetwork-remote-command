//
//  AppView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 04/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

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

@main
struct AppView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var helper = TealiumHelper.shared
    @AppStorage("sendHigherValue") var sendHigherValue = false
    @StateObject var strategyListener = StrategyListener()
    init() {
        helper.start()
    }
    func toggleSendHigherValueInDatalayer() {
        helper.tealium?.dataLayer.add(key: "application_send_higher_value", value: sendHigherValue, expiry: .forever)
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
                        Section {
                            HStack {
                                Text("Selected Strategy:")
                                Spacer()
                                Text(strategyListener.selectedStrategy)
                                    .bold()
                            }
                            
                            Text("Each strategy is a possible implementation you can take into your app. \nChose the one that best suits your needs.\nNote: in this sample the ConversionValue gets automatically reset when changing strategy")
                                .font(.system(size: 12))
                        }
                        Section {
                            NavigationLink("Simple Value Strategy", destination: SimpleValueStrategyView())
                            NavigationLink("Money Spent", destination: MoneyStrategyView())
                            NavigationLink("Jorney Steps", destination: JourneyStrategyView())
                            NavigationLink("Events Based", destination: EventStrategyView())
                            NavigationLink("Mixed Events/Steps", destination: MixedEventsStepsStrategyView())
                            NavigationLink("Mixed Value/Steps", destination: MixedValueStepsStrategyView())
                            Toggle("Send Higher Value", isOn: Binding<Bool>.init(get: {
                                self.sendHigherValue
                            }, set: { newValue in
                                helper.track(title: "configure_skadnetwork_command", data: nil)
                                self.sendHigherValue = newValue
                                toggleSendHigherValueInDatalayer()
                            }))
                            Button {
                                self.strategyListener.resetConversionValue()
                            } label: {
                                Text("Reset Conversion Value")
                            }
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
            Slider(value: intProxy, in: 0...63, onEditingChanged: { editing in
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
            spendButton(amount: 1000)
            Section {
                Text("The ConversionValue will increase by 1 for each $10 spent.\nAssuming that the app is tracking in rounded amounts, you can specify values up to $630. \nTo avoid missing higher values, you need to track $630 when the money spent is higher than $630.\nIf you want to change the ranges, for example increase by 1 for each $20 spent, you need to round the tracked value to the next $20 spent. \nFor example a spending of $31 should be rounded to $20 or $40. In this case you would lose sensitivity but gain a wider range, up to $1260.")
            }
        }.navigationTitle("Money Spent Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "money", expiry: .forever)
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
            "money_spent": min(roundedToTens(moneySpent), 630),
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
            Slider(value: intProxy, in: 0...7, onEditingChanged: { editing in
                if !editing {
                    TealiumHelper.shared.track(title: "value_change", data: ["application_fine_value": value])
                }
            })
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
                Text("The ConversionValue will be determined by two different strategies. The Value and the Journey Steps.\nYou can specify any number of bits for the value and leave 6-N bit for the journey. \nIn this case we decided to use 3 and 3. So you can put any value like (from 0 to 7) in the Value Strategy, and have steps from 0 to 7 like the Joruney Steps strategy.\nNote that Value and Steps strategies are only conceptually different and are actually implemented in the same way.")
            }
        }.navigationTitle("Mixed Value/Steps Strategy")
            .onAppear {
                TealiumHelper.shared.tealium?.dataLayer.add(key: "strategy", value: "mixed_value_steps", expiry: .forever)
            }
    }
}


