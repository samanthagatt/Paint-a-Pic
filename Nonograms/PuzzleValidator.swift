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
        // If row or col isn't valid after changing tag then entire puzzle isn't either
        guard validate(changed: tag) else { return false }
        return isValid
    }
    
    // TODO: Test
    @discardableResult
    private mutating func validate(changed tag: Int) -> Bool {
        // Find the row by dividing tag by number of columns
        // Must subtract one from tag because arrays are 0 indexed and tags start at 1
        let row = (tag - 1) / numCols
        // Get column by how much is left over after dividing by numCols
        let col = (tag - 1) % numCols
        validate(row: row)
        validate(col: col)
        return rows[row] && cols[col]
    }
    // TODO: Test
    private mutating func validate(row: Int) {
        /// Rules for row
        let rowRule = rules.rowRules[row]
        /// Array of stretches. Should exactly equal seq if valid.
        var stretches: [Int] = []
        /// Length of current stretch of filled squares
        var stretch = 0
        for col in 0..<numCols {
            // Get tag number of square
            // Add 1 since row should start at 1 not 0 for calculation
            let tag = (numRows * row) + col + 1
            // See if square is filled
            let squareIsFilled = filled.contains(tag)
            // If it is, add 1 to stretch and check to see if it breaks rule
            if squareIsFilled {
                // Make sure stretches count is smaller than rowRule's
                // If it's not then we know the rule is broken since there will be
                // more stretches in the user's puzzle than the rules
                guard stretches.count < rowRule.count else {
                    rows[row] = false
                    return
                }
                stretch += 1
                // If stretch is longer than corresponding row rule then it breaks the rules
                if stretch > rowRule[stretches.count] {
                    rows[row] = false
                    return
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
                        rows[row] = false
                        return
                    }
                    stretches.append(stretch)
                    stretch = 0
                }
            }
        }
        if stretch > 0 { stretches.append(stretch) }
        rows[row] = rowRule == stretches
    }
    // TODO: Test
    // TODO: Clean up validate(row:) and validate(col:) into one func so its DRY
    private mutating func validate(col: Int) {
        /// Rules for row
        let colRule = rules.colRules[col]
        /// Array of stretches. Should exactly equal seq if valid.
        var stretches: [Int] = []
        /// Length of current stretch of filled squares
        var stretch = 0
        for row in 0..<numRows {
            // Get tag number of square
            // Add 1 since row should start at 1 not 0 for calculation
            let tag = (numRows * row) + col + 1
            // See if square is filled
            let squareIsFilled = filled.contains(tag)
            // If it is, add 1 to stretch and check to see if it breaks rule
            if squareIsFilled {
                // Make sure stretches count is smaller than rowRule's
                // If it's not then we know the rule is broken since there will be
                // more stretches in the user's puzzle than the rules
                guard stretches.count < colRule.count else {
                    cols[col] = false
                    return
                }
                stretch += 1
                // If stretch is longer than corresponding row rule then it breaks the rules
                if stretch > colRule[stretches.count] {
                    cols[col] = false
                    return
                }
            // If the square is not filled
            } else {
                // If last square was filled that means the stretch was just broken
                if stretch > 0 {
                    // Make sure the stretch that was just broken matches row rule
                    // (Don't have to worry about stretches and rowRule counts since
                    // it's taken into account when square is filled, and stretch can't break
                    // if a square was never filled)
                    guard colRule[stretches.count] == stretch else {
                        cols[col] = false
                        return
                    }
                    stretches.append(stretch)
                    stretch = 0
                }
            }
        }
        if stretch > 0 { stretches.append(stretch) }
        cols[col] = colRule == stretches
    }
}
