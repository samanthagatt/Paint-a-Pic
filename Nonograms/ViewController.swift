//
//  ViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    let cols = [
        [1, 1],
        [1, 1, 1],
        [3],
        [1],
        [1]
    ]

    let rows = [
        [2, 1],
        [2],
        [2],
        [1],
        [2]
    ]
    
    private lazy var rules: PuzzleRules = {
        PuzzleRules(
            rowRules: FixedLengthArray(storage: rows),
            colRules: FixedLengthArray(storage: cols)
        )
    }()
    private lazy var validator: PuzzleValidator = {
        PuzzleValidator(from: rules)
    }()

    @IBOutlet weak var puzzleView: PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        puzzleView.numRows = validator.numRows
        puzzleView.numCols = validator.numCols
        puzzleView.squareWasTapped = { [weak self] squareTag in
            guard let self = self else { return false }
            let isValid = self.validator.toggle(square: squareTag)
            print("isValid", isValid)
            return true
        }
    }
}

