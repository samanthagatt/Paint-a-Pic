//
//  ProgressTracker.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/22/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct ProgressTracker {
    
    enum PuzzleState: Equatable {
        case locked, unlocked(_ completed: Bool)
    }
    
    var puzzlesLoader: PuzzlesLoader
    var completed: [TwoIntTuple: Set<UUID>] = [:]
    /// Exclusive (not including)
    var upToDict: [TwoIntTuple: Int] = [:]
    let selections: [TwoIntTuple] = [.init(5, 5), .init(10, 10),
                                     .init(15, 15), .init(20, 20),
                                     .init(25, 25)]
    
    init(loader: PuzzlesLoader = PuzzlesLoader()) {
        self.puzzlesLoader = loader
        loadProgress()
    }
    
    private func selectionToKeys(_ section: TwoIntTuple
    ) -> (completed: String, upTo: String) {
        (completed: "completed_for_\(section.description)",
            upTo: "up_to_\(section.description)")
    }
    mutating func loadProgress() {
        for selection in selections {
            let keys = selectionToKeys(selection)
            let puzzleIds = UserDefaults.standard
                .array(forKey: keys.completed) as? [String]
            let ids = Set(puzzleIds?.compactMap { UUID(uuidString: $0) } ?? [])
            completed[selection] = ids
            upToDict[selection] = UserDefaults.standard.integer(forKey: keys.upTo)
        }
    }
    mutating func complete(_ uuid: UUID, in selection: TwoIntTuple) {
        let keys = selectionToKeys(selection)
        completed[selection]?.insert(uuid)
        let upTo = upToDict[selection] ?? 0
        if uuid == getNextUUID(for: selection) {
            upToDict[selection] = upTo + 1
            UserDefaults.standard.set(upTo + 1, forKey: keys.upTo)
        }
        let value = completed[selection]?.map { $0.uuidString }
        UserDefaults.standard.set(value, forKey: keys.completed)
    }
    mutating func complete(_ i: Int, in selection: TwoIntTuple) {
        guard let puzzle = puzzlesLoader.puzzles[selection]?[i].id else { return }
        complete(puzzle, in: selection)
    }
    mutating func getState(for i: Int, in selection: TwoIntTuple) -> PuzzleState {
        let puzzles = getPuzzles(for: selection) ?? []
        guard puzzles.count > i else { return .locked }
        let uuid = puzzles[i].id
        if (completed[selection] ?? []).contains(uuid) ||
            i < upToDict[selection] ?? 0 { return .unlocked(true) }
        if i == upToDict[selection] ?? 0 { return .unlocked(false) }
        return .locked
    }
    private mutating func getNextUUID(for section: TwoIntTuple) -> UUID? {
        let puzzles = getPuzzles(for: section) ?? []
        let upTo = upToDict[section] ?? 0
        guard upTo < puzzles.count else { return nil }
        return puzzles[upTo].id
    }
    private mutating func getNextUUID(for section: Int) -> UUID? {
        let puzzles = getPuzzles(for: section) ?? []
        let selection = selections[section]
        let upTo = upToDict[selection] ?? 0
        guard upTo < puzzles.count else { return nil }
        return puzzles[upTo].id
    }
    mutating func getPuzzles(for selection: TwoIntTuple) -> [PuzzleClues]? {
        if puzzlesLoader.puzzles.isEmpty {
            puzzlesLoader.loadPuzzles()
        }
        return puzzlesLoader.puzzles[selection]
    }
    mutating func getPuzzles(for section: Int) -> [PuzzleClues]? {
        let selection = selections[section]
        if !puzzlesLoader.puzzles.isEmpty {
            puzzlesLoader.loadPuzzles()
        }
        return puzzlesLoader.puzzles[selection]
    }
}
