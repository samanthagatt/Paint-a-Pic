//
//  Puzzle.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleValidator {
    private var numRows: Int { rules.rowRules.count }
    private var numCols: Int { rules.colRules.count }
    private var rows: FixedLengthArray<Bool>
    private var cols: FixedLengthArray<Bool>
    private let rules: PuzzleRules
    
    /// Initialize a new puzzle validator with no progress from a `PuzzleRules`
    init(from rules: PuzzleRules) {
        self.rules = rules
        rows = FixedLengthArray(repeating: false,
                                count: rules.rowRules.count)
        cols = FixedLengthArray(repeating: false,
                                count: rules.colRules.count)
    }
    /// Initialize a puzzle validator from a started puzzle with some progress
    init?(
        from rules: PuzzleRules,
        rows: FixedLengthArray<Bool>,
        cols: FixedLengthArray<Bool>
    ) {
        // Make sure rows and columns progress counts line up according to the rules
        guard rules.rowRules.count == rows.count,
            rules.colRules.count == cols.count else { return nil }
        self.rules = rules
        self.rows = rows
        self.cols = cols
    }
    /// Initialize a puzzle validator from a started puzzle with some progress
    init?(from rules: PuzzleRules, rows: [Bool], cols: [Bool]) {
        // Make sure rows and columns progress counts line up according to the rules
        guard rules.rowRules.count == rows.count,
            rules.colRules.count == cols.count else { return nil }
        self.rules = rules
        self.rows = FixedLengthArray(storage: rows)
        self.cols = FixedLengthArray(storage: cols)
    }
    
    func toggle(square tag: Int) -> Bool {
        // TODO: Logic to change a square
        return validate()
    }
    private func validate() -> Bool {
        return !rows.contains(false) &&
            !cols.contains(false)
    }
}
