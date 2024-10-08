//
//  PuzzleValidator.swift
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
    /// The clues for the current puzzle. Used to check validity of rows and cols
    private let clues: PuzzleClues
    /// Computed property of number of rows based off of `clues`
    var numRows: Int { clues.rowClues.count }
    /// Computed property of number of cols based off of `clues`
    var numCols: Int { clues.colClues.count }
    /// Set of all filled in square tags for easy lookup
    private var filled: Set<Int> = []
    /// Computed property determining the validity of the current state of puzzle
    private var isValid: Bool {
        !rows.contains(false) &&
            !cols.contains(false)
    }
    
    /// Initialize a new puzzle validator with no progress from a `PuzzleClues`
    init(from clues: PuzzleClues) {
        self.clues = clues
        rows = FixedLengthArray(repeating: false,
                                count: clues.rowClues.count)
        cols = FixedLengthArray(repeating: false,
                                count: clues.colClues.count)
    }
    
    /// Fills or unfills square and returns the validity of the entire puzzle
    /// - Parameter square: the tag of the square being filled or unfilled
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

    /// Returns the validity of a row or column based off the given clue.
    /// Only to be used in `validate(row:)` and `validate(col:)`.
    /// - Parameters:
    ///     - clues: The clues for the column or row
    ///     - numSquares: The number of squres in column if validating a row,
    ///                     or row if validating a column
    ///     - tag: Function returning the tag number of current square in for loop
    ///     - index: The current index in the for loop
    private func _validate(
        clues: [Int],
        numSquares: Int,
        tag: (_ index: Int) -> Int
    ) -> Bool {
        /// Array of stretches. Should exactly equal `clue` if valid.
        var stretches: [Int] = []
        /// Length of current stretch of filled squares
        var stretch = 0
        for i in 0..<numSquares {
            // Get tag number of square
            let tag = tag(i)
            // See if current square is filled
            let squareIsFilled = filled.contains(tag)
            // If it is, add 1 to stretch and check to see if it's larger than the clue
            if squareIsFilled {
                // Make sure stretches count is smaller than clue's
                // If it's larger, we know the row or column isn't correct/valid
                guard stretches.count < clues.count else {
                    return false
                }
                stretch += 1
                // If stretch is longer than corresponding clue then it's not correct
                if stretch > clues[stretches.count] {
                    return false
                }
            // If the current square is not filled
            } else {
                // If last square was filled that means the stretch was just broken
                if stretch > 0 {
                    // Make sure the stretch that was just broken matches the clue
                    // (Don't have to worry about stretches and clues counts since
                    // it's taken into account when square is filled, and stretch can't break
                    // if a square was never filled)
                    guard clues[stretches.count] == stretch else {
                        return false
                    }
                    stretches.append(stretch)
                    stretch = 0
                }
            }
        }
        if stretch > 0 { stretches.append(stretch) }
        return clues == stretches
    }
    /// Returns the validity of a row
    private func validate(row: Int) -> Bool {
        _validate(clues: clues.rowClues[row],
                  numSquares: numCols,
                  tag: { col in
                    getTag(row: row, col: col)
        })
    }
    /// Returns the validity of a column
    private func validate(col: Int) -> Bool {
        _validate(clues: clues.colClues[col],
                  numSquares: numRows,
                  tag: { row in
                    getTag(row: row, col: col)
        })
    }
    /// Calculates the tag number of a square given the row and column
    private func getTag(row: Int, col: Int) -> Int {
        (numCols * row) + col + 1
    }
}
