//
//  MoneyStrategyView.swift
//  TealiumSKAdNetwork_Example
//
//  Created by Enrico Zannini on 09/01/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

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
