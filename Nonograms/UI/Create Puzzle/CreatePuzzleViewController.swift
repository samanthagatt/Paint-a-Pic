//
//  NewPuzzleViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/23/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class CreatePuzzleViewController: UIViewController {
    
    private var rowClues: [[Int]] = Array(repeating: [], count: 5)
    private var colClues: [[Int]] = Array(repeating: [], count: 5)
    var puzzleData: [PuzzleClues] = []
    
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
            rowClues = Array(repeating: [], count: Int(rowCountStepper.value))
            rowCountLabel.text = "\(Int(rowCountStepper.value))"
        case colCountStepper:
            colClues = Array(repeating: [], count: Int(colCountStepper.value))
            colCountLabel.text = "\(Int(colCountStepper.value))"
        default: ()
        }
        puzzleView.clues = PuzzleClues(name: nameTextField.text ?? "",
                                       rowClues: rowClues,
                                       colClues: colClues)
    }
    @IBAction func createPuzzle(_ sender: Any) {
        puzzleView.clues.name = nameTextField.text ?? ""
        let clues = puzzleView.filledSquaresAsClues()
        puzzleData.append(clues)
        
        do {
            let data = try JSONEncoder().encode(puzzleData)
            let docsDir = FileManager.default.urls(for: .documentDirectory,
                                                  in: .userDomainMask)[0]
            let path = docsDir.appendingPathComponent("puzzleData.json")
            try data.write(to: path)
        } catch {
            alert(title: "Uh oh",
                  message: "An error ocurred. Your puzzle has not been saved.",
                  dismissTitle: "Okay")
        }
    }
}
