//
//  NewPuzzleViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/23/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class CreatePuzzleViewController: UIViewController {
    
    private var rowRules: [[Int]] = Array(repeating: [], count: 5)
    private var colRules: [[Int]] = Array(repeating: [], count: 5)
    var puzzleData: [PuzzleRules] = []
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rowCountLabel: UILabel!
    @IBOutlet weak var colCountLabel: UILabel!
    @IBOutlet weak var rowCountStepper: UIStepper!
    @IBOutlet weak var colCountStepper: UIStepper!
    @IBOutlet weak var puzzleView: PuzzleView!
    
    @IBAction func dissmissKeyboard(_ sender: Any) {
        nameTextField.resignFirstResponder()
    }
    @IBAction func changeCount(_ sender: UIStepper) {
        switch sender {
        case rowCountStepper:
            rowRules = Array(repeating: [], count: Int(rowCountStepper.value))
            rowCountLabel.text = "\(Int(rowCountStepper.value))"
        case colCountStepper:
            colRules = Array(repeating: [], count: Int(colCountStepper.value))
            colCountLabel.text = "\(Int(colCountStepper.value))"
        default: ()
        }
        puzzleView.rules = PuzzleRules(name: nameTextField.text ?? "",
                                       rowRules: rowRules,
                                       colRules: colRules)
    }
    @IBAction func createPuzzle(_ sender: Any) {
        print(nameTextField.text ?? "No name!")
        puzzleView.rules.name = nameTextField.text ?? ""
        let rules = puzzleView.filledSquaresAsRules()
        puzzleData.append(rules)
        
        do {
            let data = try JSONEncoder().encode(puzzleData)
            let docsDir = FileManager.default.urls(for: .documentDirectory,
                                                  in: .userDomainMask)[0]
            let path = docsDir.appendingPathComponent("puzzleData.json")
            print(path)
            try data.write(to: path)
        } catch {
            print("Oops! ERROR: \(error)")
        }
    }
}
