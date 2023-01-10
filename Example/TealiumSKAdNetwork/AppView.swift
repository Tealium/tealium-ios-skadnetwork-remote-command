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
                            NavigationLink("Journey Steps", destination: JourneyStrategyView())
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
