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
enum PuzzleSquareFillState: Equatable {
    case filled, empty, exed
    mutating func setNewState(for mode: PuzzleFillMode) {
        switch mode {
        case .fill:
            switch self {
            case .filled: self = .empty
            case .empty: self = .filled
            case .exed: self = .exed
            }
        case .ex:
            switch self {
            case .empty: self = .exed
            case .exed: self = .empty
            case .filled: self = .filled
            }
        }
    }
    func getTempFillMode(_ mode: PuzzleFillMode) -> TempFillMode? {
        switch self {
        case .filled:
            switch mode {
            case .ex: return nil
            case .fill: return .erase(mode: .fill)
            }
        case .empty:
            switch mode {
            case .ex: return .ex
            case .fill: return .fill
            }
        case .exed:
            switch mode {
            case .ex: return .erase(mode: .ex)
            case .fill: return nil
            }
        }
    }
    func getStateAfterTempFill(_ mode: TempFillMode) -> PuzzleSquareFillState? {
        switch self {
        case .filled:
            switch mode {
            case .ex, .fill: return nil
            case .erase(mode: let eraseMode):
                switch eraseMode {
                case .ex: return nil
                case .fill: return .empty
                }
            }
        case .empty:
            switch mode {
            case .ex: return .exed
            case .fill: return .filled
            case .erase: return nil
            }
        case .exed:
            switch mode {
            case .ex, .fill: return nil
            case .erase(mode: let eraseMode):
                switch eraseMode {
                case .ex: return .empty
                case .fill: return nil
                }
            }
        }
    }
}

enum TempFillMode {
    case ex, fill, erase(mode: PuzzleFillMode)
}
