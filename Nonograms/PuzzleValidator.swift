//
//  Puzzle.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleValidator {
    private var rows: FixedLengthArray<Bool>
    private var cols: FixedLengthArray<Bool>
    private let rules: PuzzleRules
    private var numRows: Int { rules.rowRules.count }
    private var numCols: Int { rules.colRules.count }
    private var filled: Set<Int>
    private var isValid: Bool {
        return !rows.contains(false) &&
            !cols.contains(false)
    }
    
    /// Initialize a new puzzle validator with no progress from a `PuzzleRules`
    init(from rules: PuzzleRules, filled: Set<Int> = []) {
        self.rules = rules
        rows = FixedLengthArray(repeating: false,
                                count: rules.rowRules.count)
        cols = FixedLengthArray(repeating: false,
                                count: rules.colRules.count)
        self.filled = filled
        for i in 0...rules.rowRules.count {
            rows[i] = validate(row: i)
        }
    }
    
    func toggle(square tag: Int) -> Bool {
        return isValid
    }
    
    private func validate(row: Int) -> Bool {
        /// Rules for row
        let rowRule = rules.rowRules[row]
        /// Array of stretches. Should exactly equal seq if valid.
        var stretches: [Int] = []
        /// Length of current stretch of filled squares
        var stretch = 0
        for col in 0..<numCols {
            // Get tag number of square
            // Add 1 since row should start at 1 not 0 for calculation
            let tag = (numRows * col) + row + 1
            // See if square is filled
            let squareIsFilled = filled.contains(tag)
            // If it is, add 1 to stretch and check to see if it breaks rule
            if squareIsFilled {
                // Make sure stretches count is smaller than rowRule's
                // If it's not then we know the rule is broken since there will be
                // more stretches in the user's puzzle than the rules
                guard stretches.count < rowRule.count else { return false }
                stretch += 1
                // If stretch is longer than corresponding row rule then it breaks the rules
                if stretch > rowRule[stretches.count] {
                    return false
                }
            // If the square is not filled
            } else {
                // If last square was filled that means the stretch was just broken
                if stretch > 0 {
                    // Make sure the stretch that was just broken matches row rule
                    // (Don't have to worry about stretches and rowRule counts since
                    // it's taken into account when square is filled, and stretch can't break
                    // if a square was never filled)
                    guard rowRule[stretches.count] == stretch else {
                        return false
                    }
                    stretches.append(stretch)
                    stretch = 0
                }
            }
        }
        return rowRule == stretches
    }
    private func validate(col: Int) -> Bool {
        return true
    }
}
