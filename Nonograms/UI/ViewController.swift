//
//  ViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit
import Combine

final class ViewController: UIViewController {
    /// Set of all subscriptions. Each will be canceled on deallocation.
    private var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var puzzleView: PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        puzzleView.rules = PuzzleRules(
            rowRules: [[1,1], [1,1,1], [1,1], [1,1], [1]],
            colRules: [[2], [1,1], [1,1], [1,1], [2]]
        )
        // Subscribe to updates to see if puzzle has been solved
        puzzleView.puzzleValidity.sink { [weak self] isValid in
            guard let self = self else { return }
            if isValid {
                let alert = UIAlertController(title: "Yay!", message: "You solved the puzzle :)", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default)
                alert.addAction(okayAction)
                self.present(alert, animated: true)
            }
        }.store(in: &subscriptions)
    }
}

