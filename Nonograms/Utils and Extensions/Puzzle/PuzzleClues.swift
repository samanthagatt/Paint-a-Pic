//
//  PuzzleClues.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleClues: Equatable, Codable {
    let id: UUID
    var name: String
    let rowClues: FixedLengthArray<[Int]>
    let colClues: FixedLengthArray<[Int]>
    init(
        id: UUID = UUID(),
        name: String,
        rowClues: FixedLengthArray<[Int]>,
        colClues: FixedLengthArray<[Int]>
    ) {
        self.id = id
        self.name = name
        self.rowClues = rowClues
        self.colClues = colClues
    }
    init(
        name: String,
        rowClues: [[Int]],
        colClues: [[Int]]
    ) {
        self.init(name: name,
                  rowClues: FixedLengthArray(storage: rowClues),
                  colClues: FixedLengthArray(storage: colClues))
    }
}

// MARK: Codable
extension PuzzleClues {
    enum CodingKeys: String, CodingKey {
        case id, name, rowClues, colClues, isComplete
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(rowClues.storage, forKey: .rowClues)
        try container.encode(colClues.storage, forKey: .colClues)
        try container.encode(id.uuidString, forKey: .id)
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        let rowCluesStorage = try values.decode([[Int]].self, forKey: .rowClues)
        let colCluesStorage = try values.decode([[Int]].self, forKey: .colClues)
        rowClues = FixedLengthArray(storage: rowCluesStorage)
        colClues = FixedLengthArray(storage: colCluesStorage)
    }
}
