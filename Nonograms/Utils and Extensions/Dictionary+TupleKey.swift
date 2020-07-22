//
//  Dictionary+TupleKey.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/19/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct TupleStruct: Hashable {
    let int0: Int
    let int1: Int
    
    init(_ pair: (Int, Int)) {
        self.int0 = pair.0
        self.int1 = pair.1
    }
}

// MARK: Codable
/*
extension TupleStruct {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([String(int0), String(int1)].joined(separator: "x"))
    }
    init(from decoder: Decoder) throws {
        let values = try decoder
            .singleValueContainer()
            .decode(String.self)
            .split(separator: "x")
        int0 = Int(values.first ?? "5") ?? 5
        int1 = Int(values.last ?? "5") ?? 5
    }
}
 */

extension Dictionary where Key == TupleStruct {
    subscript (key: (Int, Int)) -> Value? {
        get { self[Key(key)] }
        set { self[Key(key)] = newValue }
    }
}
