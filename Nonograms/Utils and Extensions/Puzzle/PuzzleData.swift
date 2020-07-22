//
//  PuzzleData.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/21/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleData: Codable {
    var puzzles: [TupleStruct: [PuzzleClues]] = [:]
}

extension PuzzleData {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = puzzles.reduce([:]) { (dict, pair) -> [String: [PuzzleClues]] in
            var dict = dict
            let key = "\(pair.key.int0)x\(pair.key.int1)"
            dict[key] = pair.value
            return dict
        }
        try container.encode(data)
    }
    init(from decoder: Decoder) throws {
        let value = try decoder
            .singleValueContainer()
            .decode([String: [PuzzleClues]].self)
        puzzles = value.reduce([:]) { dict, pair in
            var dict = dict
            let ints = pair.key.split(separator: "x")
            let key = (Int(ints.first ?? "5") ?? 5, Int(ints.last ?? "5") ?? 5)
            dict[key] = pair.value
            return dict
        }
    }
}
