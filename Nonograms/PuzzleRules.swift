//
//  PuzzleRules.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import Foundation

struct PuzzleRules: Equatable {
    let rowRules: FixedLengthArray<[Int]>
    let colRules: FixedLengthArray<[Int]>
}
