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
    func getTempMode(from mode: PuzzleFillMode) -> PuzzleTempFillMode {
        switch self {
        case .filled: return mode == .fill ? .erase(mode) : .doNothing
        case .empty: return .init(from: mode)
        case .exed: return mode == .ex ? .erase(mode) : .doNothing
        }
    }
    func getNewState(for mode: PuzzleTempFillMode) -> PuzzleSquareFillState? {
        switch mode {
        case .ex: return self == .empty ? .exed : nil
        case .fill: return self == .empty ? .filled : nil
        case .erase(let eraseMode):
            switch self {
            case .filled: return eraseMode == .fill ? .empty : nil
            case .exed: return eraseMode == .ex ? .empty : nil
            case .empty: return nil
            }
        case .doNothing: return nil
        }
    }
}

enum PuzzleTempFillMode {
    case ex, fill, erase(PuzzleFillMode), doNothing
    init(from mode: PuzzleFillMode) {
        self = mode == .fill ? .fill : .ex
    }
}
