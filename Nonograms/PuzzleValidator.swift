//
//  Puzzle.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleValidator {
    /// Keeps track of validity of each row in order
    private var rows: FixedLengthArray<Bool>
    /// Keeps track of validity of each column in order
    private var cols: FixedLengthArray<Bool>
    /// The rules for the current puzzle. Used to check validity of rows and cols
    private let rules: PuzzleRules
    /// Computed property of number of rows based off of rules
    var numRows: Int { rules.rowRules.count }
    /// Computed property of number of cols based off of rules
    var numCols: Int { rules.colRules.count }
    /// Set of all filled in square tags for easy lookup
    private var filled: Set<Int> = []
    private var isValid: Bool {
        return !rows.contains(false) &&
            !cols.contains(false)
    }
    
    /// Initialize a new puzzle validator with no progress from a `PuzzleRules`
    init(from rules: PuzzleRules) {
        self.rules = rules
        rows = FixedLengthArray(repeating: false,
                                count: rules.rowRules.count)
        cols = FixedLengthArray(repeating: false,
                                count: rules.colRules.count)
    }
    
    mutating func toggle(square tag: Int) -> Bool {
        filled.toggle(tag)
        // Find the row by dividing tag by number of columns
        // Must subtract one from tag because arrays are 0 indexed and tags start at 1
        let row = (tag - 1) / numCols
        // Get column by how much is left over after dividing by numCols
        let col = (tag - 1) % numCols
        rows[row] = validate(row: row)
        cols[col] = validate(col: col)
        // If row or col isn't valid after changing tag then entire puzzle isn't either
        guard rows[row] && cols[col] else { return false }
        return isValid
    }

    private func validate(
        rule: [Int],
        numSquares: Int,
        tag: (_ index: Int) -> Int
    ) -> Bool {
        /// Array of stretches. Should exactly equal rule if valid.
        var stretches: [Int] = []
        /// Length of current stretch of filled squares
        var stretch = 0
        for i in 0..<numSquares {
            // Get tag number of square
            let tag = tag(i)
            // See if current square is filled
            let squareIsFilled = filled.contains(tag)
            // If it is, add 1 to stretch and check to see if it breaks rule
            if squareIsFilled {
                // Make sure stretches count is smaller than rowRule's
                // If it's not then we know the rule is broken since there will be
                // more stretches in the user's puzzle than the rules
                guard stretches.count < rule.count else {
                    return false
                }
                stretch += 1
                // If stretch is longer than corresponding row rule then it breaks the rules
                if stretch > rule[stretches.count] {
                    return false
                }
            // If the current square is not filled
            } else {
                // If last square was filled that means the stretch was just broken
                if stretch > 0 {
                    // Make sure the stretch that was just broken matches row rule
                    // (Don't have to worry about stretches and rowRule counts since
                    // it's taken into account when square is filled, and stretch can't break
                    // if a square was never filled)
                    guard rule[stretches.count] == stretch else {
                        return false
                    }
                    stretches.append(stretch)
                    stretch = 0
                }
            }
        }
        if stretch > 0 { stretches.append(stretch) }
        return rule == stretches
    }
    private func validate(row: Int) -> Bool {
        validate(rule: rules.rowRules[row],
                 numSquares: numCols,
                 tag: { col in
                    getTag(row: row, col: col)
        })
    }
    private func validate(col: Int) -> Bool {
        validate(rule: rules.colRules[col],
                 numSquares: numRows,
                 tag: { row in
                    getTag(row: row, col: col)
        })
    }
    private func getTag(row: Int, col: Int) -> Int {
        (numRows * row) + col + 1
    }
}
