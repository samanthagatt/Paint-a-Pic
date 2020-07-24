//
//  FixedLengthArray.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

/// Array that has a fixed length. Cannot append or remove an element.
struct FixedLengthArray<T: Equatable>: Equatable {
    /// Internal array to store elements
    private(set) var storage: [T]
    var count: Int { storage.count }
    
    /// Init `FixedLengthArray` containing an element repeated `n` number of times
    /// - Parameter repeating: Element to be repeated
    /// - Parameter count: Number of times element will be repeated
    init(repeating: T, count: Int) {
        storage = Array(repeating: repeating, count: count)
    }
    /// Init from `Array`
    init(storage: [T]) {
        self.storage = storage
    }
}

// MARK: Allow subscripting
extension FixedLengthArray {
    subscript(index: Int) -> T {
        get { storage[index] }
        set { storage[index] = newValue }
    }
}

// MARK: Allow initialization from an array literal
extension FixedLengthArray: ExpressibleByArrayLiteral {
    init(arrayLiteral: T...) {
        self.init(storage: arrayLiteral)
    }
}

// MARK: Allow iteration
extension FixedLengthArray: Sequence {
    func makeIterator() -> FLAIterator<T> {
        FLAIterator(fla: self)
    }
}

// MARK: - Iterator for `FixedLengthArray`
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
