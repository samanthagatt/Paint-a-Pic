//
//  PuzzleRules.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleRules: Equatable, Codable {
    var name: String
    let rowRules: FixedLengthArray<[Int]>
    let colRules: FixedLengthArray<[Int]>
    
    init(
        name: String,
        rowRules: FixedLengthArray<[Int]>,
        colRules: FixedLengthArray<[Int]>
    ) {
        self.name = name
        self.rowRules = rowRules
        self.colRules = colRules
    }
    init(name: String, rowRules: [[Int]], colRules: [[Int]]) {
        self.name = name
        self.rowRules = FixedLengthArray(storage: rowRules)
        self.colRules = FixedLengthArray(storage: colRules)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, rowRules, colRules
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(rowRules.storage, forKey: .rowRules)
        try container.encode(colRules.storage, forKey: .colRules)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        let rowRulesStorage = try values.decode([[Int]].self, forKey: .rowRules)
        let colRulesStorage = try values.decode([[Int]].self, forKey: .colRules)
        rowRules = FixedLengthArray(storage: rowRulesStorage)
        colRules = FixedLengthArray(storage: colRulesStorage)
    }
}
