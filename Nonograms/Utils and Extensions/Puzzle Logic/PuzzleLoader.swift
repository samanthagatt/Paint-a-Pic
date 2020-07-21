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
    private(set) var puzzles: [IntPairStruct: [PuzzleClues]]?
    
    mutating func getPuzzles(for section: Int) -> [PuzzleClues] {
        if let puzzles = puzzles {
            guard sections.count > section else { return [] }
            return puzzles[sections[section]] ?? []
        } else {
            loadPuzzles()
            return puzzles?[sections[section]] ?? []
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
            let puzzleData = try JSONDecoder().decode([String: [PuzzleClues]].self, from: data)
            puzzles = puzzleData.reduce([:]) { dict, pair in
                var dict = dict ?? [:]
                let ints = pair.key.split(separator: "x")
                let key = (Int(ints.first ?? "0") ?? 0, Int(ints.last ?? "0") ?? 0)
                dict[key] = pair.value
                return dict
            }
        } catch {
            return
        }
    }
}
