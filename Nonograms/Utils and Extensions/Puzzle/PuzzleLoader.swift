//
//  PuzzleLoader.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleLoader {
    
    private let sections = [(5, 5), (10, 10), (15, 15), (20, 20), (25, 25)]
    private(set) var puzzleData = PuzzleData()
    var puzzles: [TupleStruct: [PuzzleClues]] {
        puzzleData.puzzles
    }
    
    mutating func getPuzzles(for selection: Int) -> [PuzzleClues]? {
        if !puzzles.isEmpty {
            guard selection >= 0,
                sections.count > selection else { return puzzles[(5, 5)] }
            return puzzles[sections[selection]]
        } else {
            loadPuzzles()
            return puzzles[sections[selection]]
        }
    }
    mutating func loadPuzzles() {
        let docsPath = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("puzzleData.json")
        let bundlePath = Bundle.main.url(forResource: "puzzleData",
                                         withExtension: "json")
        do {
            let data: Data
            if FileManager.default.fileExists(atPath: docsPath.absoluteString) &&
                UserDefaults.standard.bool(forKey: "hasGottenPuzzles") {
                data = try Data(contentsOf: docsPath)
            } else {
                guard let bundlePath = bundlePath else { return }
                data = try Data(contentsOf: bundlePath)
                try data.write(to: docsPath)
                UserDefaults.standard.set(true, forKey: "hasGottenPuzzles")
            }
            puzzleData = try JSONDecoder().decode(PuzzleData.self, from: data)
        } catch {
            print(error)
            return
        }
    }
}
