//
//  PuzzlesLoader.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzlesLoader {
    
    var puzzles: [TwoIntTuple: [PuzzleClues]] = [:]
    
    mutating func loadPuzzles() {
        guard let bundlePath = Bundle.main
            .url(forResource: "puzzleData", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: bundlePath)
            puzzles = try JSONDecoder().decode([String: [PuzzleClues]].self,
                                               from: data).toTupleKey()
        } catch {
            print(error)
            return
        }
    }
}
