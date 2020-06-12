//
//  Set+Toggle.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

extension Set {
    mutating func toggle(_ item: Element) {
        if contains(item) {
            remove(item)
        } else {
            insert(item)
        }
    }
}
