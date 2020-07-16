//
//  MutableCollection+MapInPlace.swift
//  Nonograms
//
//  Created by Samantha Gatt on 7/14/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

extension MutableCollection {
    /// Allows elements in arrays of `struct`s to be mutated during mapping
    /// - parameter closure: Block of code to be run during iteration
    mutating func mapInPlace(_ closure: (inout Element) -> ()) {
        for i in indices { closure(&self[i]) }
    }
}
