//
//  MutableCollection+MapInPlace.swift
//  Nonograms
//
//  Created by Samantha Gatt on 7/14/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

extension MutableCollection {
    mutating func mapInPlace(_ x: (inout Element) -> ()) {
        for i in indices {
            x(&self[i])
        }
    }
}
