//
//  Dictionary+TupleKey.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/19/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct IntPairStruct: Hashable {
    let int0: Int
    let int1: Int
    
    init(_ pair: (Int, Int)) {
        self.int0 = pair.0
        self.int1 = pair.1
    }
}

extension Dictionary where Key == IntPairStruct {
    subscript (key: (Int, Int)) -> Value? {
        get { self[Key(key)] }
        set { self[Key(key)] = newValue }
    }
}
