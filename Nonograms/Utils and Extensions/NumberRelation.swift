//
//  NumberRelation.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

enum NumberRelation {
    case lessThan, equalTo, greaterThan
}

extension BinaryInteger {
    func relation(to comparative: Self) -> NumberRelation {
        if self < comparative {
            return .lessThan
        } else if self == comparative {
            return .equalTo
        } else {
            return .greaterThan
        }
    }
}

extension BinaryFloatingPoint {
    func relation(to comparative: Self) -> NumberRelation {
        if self < comparative {
            return .lessThan
        } else if self == comparative {
            return .equalTo
        } else {
            return .greaterThan
        }
    }
}
