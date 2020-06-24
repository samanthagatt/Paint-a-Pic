//
//  FixedLengthArray.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct FixedLengthArray<T: Equatable>: Equatable {
    private(set) var storage: [T]
    var count: Int { storage.count }
    
    init(repeating: T, count: Int) {
        storage = Array(repeating: repeating, count: count)
    }
    init(storage: [T]) {
        self.storage = storage
    }
}

extension FixedLengthArray {
    subscript(index: Int) -> T {
        get { storage[index] }
        set { storage[index] = newValue }
    }
}

extension FixedLengthArray: ExpressibleByArrayLiteral {
    init(arrayLiteral: T...) {
        self.init(storage: arrayLiteral)
    }
}

extension FixedLengthArray: Sequence {
    func makeIterator() -> FLAIterator<T> {
        FLAIterator(fla: self)
    }
}

struct FLAIterator<T: Equatable>: IteratorProtocol {
    let fla: FixedLengthArray<T>
    var currentIndex = 0
    mutating func next() -> T? {
        if currentIndex < fla.count {
            defer { currentIndex += 1 }
            return fla[currentIndex]
        }
        return nil
    }
}
