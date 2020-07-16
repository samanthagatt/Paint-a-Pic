//
//  PuzzleClues.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleClues: Equatable, Codable {
    var name: String
    let rowClues: FixedLengthArray<[Int]>
    let colClues: FixedLengthArray<[Int]>
    var isComplete: Bool = false
    init(
        name: String,
        rowClues: FixedLengthArray<[Int]>,
        colClues: FixedLengthArray<[Int]>,
        isComplete: Bool = false
    ) {
        self.name = name
        self.rowClues = rowClues
        self.colClues = colClues
        self.isComplete = isComplete
    }
    init(
        name: String,
        rowClues: [[Int]],
        colClues: [[Int]],
        isComplete: Bool = false
    ) {
        self.init(name: name,
                  rowClues: FixedLengthArray(storage: rowClues),
                  colClues: FixedLengthArray(storage: colClues),
                  isComplete: isComplete)
    }
}

// MARK: Codable
extension PuzzleClues {
    enum CodingKeys: String, CodingKey {
        case name, rowClues, colClues, isComplete
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(rowClues.storage, forKey: .rowClues)
        try container.encode(colClues.storage, forKey: .colClues)
        try container.encode(isComplete, forKey: .isComplete)
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        isComplete = try values.decodeIfPresent(Bool.self,
                                                forKey: .isComplete) ?? false
        let rowCluesStorage = try values.decode([[Int]].self, forKey: .rowClues)
        let colCluesStorage = try values.decode([[Int]].self, forKey: .colClues)
        rowClues = FixedLengthArray(storage: rowCluesStorage)
        colClues = FixedLengthArray(storage: colCluesStorage)
    }
}
