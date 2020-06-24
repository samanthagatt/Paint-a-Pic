//
//  PuzzleMaker.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/23/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleMaker {
    var name: String
    let numRows: Int
    let numCols: Int
    var filled: Set<Int> = []
    
    init(name: String, numRows: Int, numCols: Int) {
        self.name = name
        self.numRows = numRows
        self.numCols = numCols
    }
    
    func getRules() -> PuzzleRules {
        var rowRules: [[Int]] = []
        var colRules: [[Int]] = []
        for col in 0..<numCols {
            var stretches: [Int] = []
            var currentStretch = 0
            for row in 0..<numRows {
                let square = (numCols * row) + col + 1
                if filled.contains(square) {
                    currentStretch += 1
                } else if currentStretch > 0 {
                    stretches.append(currentStretch)
                    currentStretch = 0
                }
            }
            if currentStretch > 0 { stretches.append(currentStretch) }
            colRules.append(stretches)
        }
        for row in 0..<numRows {
            var stretches: [Int] = []
            var currentStretch = 0
            for col in 0..<numCols {
                let square = (numCols * row) + col + 1
                if filled.contains(square) {
                    currentStretch += 1
                } else if currentStretch > 0 {
                    stretches.append(currentStretch)
                    currentStretch = 0
                }
            }
            if currentStretch > 0 { stretches.append(currentStretch) }
            rowRules.append(stretches)
        }
        return PuzzleRules(name: name, rowRules: rowRules, colRules: colRules)
    }
}
