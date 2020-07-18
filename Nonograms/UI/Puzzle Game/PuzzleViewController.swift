//
//  PuzzleViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit
import Combine

final class PuzzleViewController: UIViewController {
    /// Set of all subscriptions. Each will be canceled on deallocation.
    private var subscriptions = Set<AnyCancellable>()
    /// Bool to keep track if the puzzle has been edited
    /// Should be reset once puzzle has been solved
    private var hasBeenEdited = false
    /// Index of current puzzle
    var puzzleIndex: Int?
    /// Clues for the current puzzle
    var puzzleClues: PuzzleClues? {
        didSet {
            if let clues = puzzleClues {
                loadViewIfNeeded()
                puzzleView.clues = clues
                title = clues.name.capitalized
            }
        }
    }

    @IBOutlet private weak var puzzleView: PuzzleView!
    @IBOutlet private weak var exButton: UIButton!
    @IBOutlet private weak var fillButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        // Subscribe to updates to see if puzzle has been solved
        puzzleView.puzzleValidity.sink { [weak self] isValid in
            guard let self = self else { return }
            if !self.hasBeenEdited { self.hasBeenEdited = true }
            if isValid {
                NotificationCenter.default.post(name: .puzzleSolved,
                                                object: self.puzzleIndex)
                self.alert(title: "Yay!",
                           message: "You solved the puzzle :)",
                           dismissTitle: "Okay")
                self.hasBeenEdited = false
            }
        }.store(in: &subscriptions)
        puzzleView.squaresTooSmall.sink { [weak self] isTooSmall in
            guard let self = self else { return }
            if isTooSmall {
                self.alert(title: "Uh oh",
                           message: """
                           It looks like your device might be too small.\
                           Tapping the correct square might be harder than normal
                           """,
                           dismissTitle: "Okay")
            }
        }.store(in: &subscriptions)
    }
    
    private func setupViews() {
        exButton.layer.borderColor = UIColor.label.cgColor
        exButton.layer.cornerRadius = 5
        fillButton.layer.borderColor = UIColor.label.cgColor
        fillButton.layer.borderWidth = 2
        fillButton.layer.cornerRadius = 5
        
//        let saveButton = UIBarButtonItem(barButtonSystemItem: .save,
//                                         target: self,
//                                         action: #selector(saveImage))
//        navigationItem.setRightBarButton(saveButton, animated: true)
    }
    
    @objc private func back() {
        if hasBeenEdited {
            alert(title: "Go back?",
                message: """
                You've already started this puzzle. \
                Are you sure you want to go back? \
                All your progress will be lost.
                """,
                actions: [
                    UIAlertAction(title: "Cancel", style: .cancel),
                    UIAlertAction(title: "Go Back",
                                  style: .destructive) { _ in
                        self.navigationController?
                            .popViewController(animated: true)
                    }
                ]
            )
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func setExMode(_ sender: Any) {
        exButton.layer.borderWidth = 2
        fillButton.layer.borderWidth = 0
        puzzleView.fillMode = .ex
    }
    @IBAction func setFillMode(_ sender: Any) {
        fillButton.layer.borderWidth = 2
        exButton.layer.borderWidth = 0
        puzzleView.fillMode = .fill
    }
    
    @objc func saveImage() {
        guard let image = puzzleView.image else { return }
        do {
            let docsDir = FileManager.default.urls(for: .documentDirectory,
                                                  in: .userDomainMask)[0]
            let path = docsDir.appendingPathComponent("\(title ?? "no title").png")
            print(path)
            try image.pngData()?.write(to: path)
        } catch {
            alert(title: "Uh oh",
                  message: "An error ocurred. Your puzzle has not been saved.",
                  dismissTitle: "Okay")
        }
    }
}
