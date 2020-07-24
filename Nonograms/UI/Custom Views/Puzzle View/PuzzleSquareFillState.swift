//
//  PuzzleSquareFillState.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

enum PuzzleFillMode {
    case ex, fill
}
enum PuzzleSquareFillState {
    case filled, empty, exed
    mutating func setNewState(for mode: PuzzleFillMode) {
        switch mode {
        case .fill: switch self {
            case .filled: self = .empty
            case .empty: self = .filled
            case .exed: self = .exed
            }
        case .ex: switch self {
            case .empty: self = .exed
            case .exed: self = .empty
            case .filled: self = .filled
            }
        }
    }
}
