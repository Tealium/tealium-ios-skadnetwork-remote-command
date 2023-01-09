//
//  ValueBitLimiter.swift
//  TealiumSKAdNetwork
//
//  Created by Enrico Zannini on 09/01/23.
//

import Foundation

class ValueBitLimiter {
    enum SideLimit {
        case left(Int)
        case right(Int)
    }
    let nBit: Int
    let maximum: Int
    init(nBit: Int = 6) {
        self.nBit = nBit
        self.maximum = Int(pow(Double(2), Double(nBit))-1)
    }
    func bitMask(left: Int) -> Int {
        maximum & maximum << (nBit-left)
    }
    func bitMask(right: Int) -> Int {
        maximum >> (nBit-right)
    }
    
    func setValue(_ newValue: Int, on storedValue: Int, fromLeftLimitedTo leftLimit: Int) -> Int {
        let remainingBits = nBit-leftLimit
        return (storedValue & bitMask(right: remainingBits)) | (newValue << remainingBits & bitMask(left: leftLimit))
    }

    func setValue(_ newValue: Int, on storedValue: Int, fromRightLimitedTo rightLimit: Int) -> Int {
        let remainingBits = nBit-rightLimit
        return (storedValue & bitMask(left: remainingBits)) | (newValue & bitMask(right: rightLimit))
    }
    
    func setValue(_ newValue: Int, on storedValue: Int, fromSideLimit sideLimit: SideLimit) -> Int {
        switch sideLimit {
        case .left(let limit):
            return setValue(newValue, on: storedValue, fromLeftLimitedTo: limit)
        case .right(let limit):
            return setValue(newValue, on: storedValue, fromRightLimitedTo: limit)
        }
    }
}
