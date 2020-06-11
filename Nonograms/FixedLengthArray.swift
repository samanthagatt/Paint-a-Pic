//
//  FixedLengthArray.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct FixedLengthArray<T: Equatable>: Equatable {
    private var storage: [T]
    var count: Int { storage.count }
    
    subscript(index: Int) -> T {
        get { storage[index] }
        set {
            storage[index] = newValue
        }
    }
    
    init(repeating: T, count: Int) {
        storage = Array(repeating: repeating, count: count)
    }
    init(storage: [T]) {
        self.storage = storage
    }
    
    func contains(_ element: T) -> Bool {
        storage.contains(element)
    }
}
