//
//  Dictionary+TupleKey.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/19/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct TwoIntTuple: Hashable, CustomStringConvertible {
    
    let int0: Int
    let int1: Int
    
    init(_ pair: (Int, Int)) {
        int0 = pair.0
        int1 = pair.1
    }
    init(_ int0: Int, _ int1: Int) {
        self.int0 = int0
        self.int1 = int1
    }
    init?(from string: String) {
        let ints = string.split(separator: "x")
        guard let first = ints.first,
            let last = ints.last,
            let int0 = Int("\(first)"),
            let int1 = Int("\(last)") else { return nil }
        self.int0 = int0
        self.int1 = int1
    }
}

// MARK: String convertable
extension TwoIntTuple {
    var description: String { "\(int0)x\(int1)" }
}

// MARK: Dictionary subscriptable
extension Dictionary where Key == TwoIntTuple {
    subscript (key: (Int, Int)) -> Value? {
        get { self[Key(key)] }
        set { self[Key(key)] = newValue }
    }
}

// MARK: Converting to string key from tuple key
extension Dictionary where Key == TwoIntTuple {
    func toStringKey() -> [String: Value] {
        reduce([:]) { dict, pair in
            var dict = dict
            dict[pair.key.description] = pair.value
            return dict
        }
    }
}

// MARK: Converting from string key to tuple key
extension Dictionary where Key == String {
    func toTupleKey() -> [TwoIntTuple: Value] {
        reduce([:]) { dict, pair in
            var dict = dict
            if let tuple = TwoIntTuple(from: pair.key) {
                dict[tuple] = pair.value
            }
            return dict
        }
    }
}
