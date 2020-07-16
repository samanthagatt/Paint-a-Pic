//
//  Set+Toggle.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

extension Set {
    /// Removes item from set if present, and adds it if absent
    /// - Parameter item: The item to be added or removed from set
    mutating func toggle(_ item: Element) {
        if contains(item) {
            remove(item)
        } else {
            insert(item)
        }
    }
}
