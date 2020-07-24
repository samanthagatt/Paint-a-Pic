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
    /// Index of current puzzle
    var puzzleIndex: Int? {
        didSet {
            if let i = puzzleIndex, let clues = puzzles?[i] {
                loadViewIfNeeded()
                puzzleView.clues = clues
            }
        }
    }
    /// Clues for the current puzzle
    var puzzles: [PuzzleClues]?
    var shouldShowNext: () -> Bool = { false }
    
    @IBOutlet weak var puzzleView: PuzzleView!
    @IBOutlet private weak var exButton: UIButton!
    @IBOutlet private weak var fillButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        // Subscribe to updates to see if puzzle has been solved
        puzzleView.puzzleValidity.sink { [weak self] isValid in
            if isValid { self?.alertPuzzleCompleted() }
        }.store(in: &subscriptions)
        puzzleView.squaresTooSmall.sink { [weak self] isTooSmall in
            if isTooSmall {
                self?.alert(title: "Uh oh",
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
        
        menuButton.contentVerticalAlignment = .fill
        menuButton.contentHorizontalAlignment = .fill
        menuButton.imageView?.contentMode = .scaleAspectFit
        
        //  let saveButton = UIBarButtonItem(barButtonSystemItem: .save,
        //                                   target: self,
        //                                   action: #selector(saveImage))
        //  navigationItem.setRightBarButton(saveButton, animated: true)
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
    func alertPuzzleCompleted() {
        guard let i = puzzleIndex, let puzzles = puzzles else { return }
        let message = i < puzzles.count ? "You solved the puzzle :)" :
            "You completed all the puzzles in this collection :)"
        let title = i < puzzles.count ? "Next" : "Exit"
        let handler = i < puzzles.count ? { (_: UIAlertAction) in
            self.puzzleIndex = i + 1
        } : { _ in
            self.dismiss(animated: true)
        }
        alert(title: "Yay!",
              message: message,
              actions: [
                UIAlertAction(title: "Okay", style: .cancel),
                UIAlertAction(title: title, style: .default,  handler: handler)
            ]
        )
    }
    @IBAction func alertMenu(_ sender: UIButton) {
        alert(title: "Menu", preferredStyle: .actionSheet, source: sender,
              animated: true, actions: [
                UIAlertAction(title: "Cancel", style: .cancel),
                UIAlertAction(title: "Quit", style: .default,
                              handler: { _ in self.dismiss(animated: true) }),
                UIAlertAction(title: "Restart", style: .default,
                              handler: { _ in self.puzzleView.clear() }),
                shouldShowNext() ?
                    UIAlertAction(title: "Next", style: .default,
                                  handler: { _ in self.puzzleIndex =
                                    (self.puzzleIndex ?? 0) + 1 }) : nil
                ].compactMap() { $0 }
        )
    }
}
