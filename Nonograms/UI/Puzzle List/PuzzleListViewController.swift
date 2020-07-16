//
//  PuzzleListViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class PuzzleListViewController: UIViewController {
    private static let solveSegueID = "solvePuzzleSegue"
    private static let createSegueID = "createPuzzleSegue"
    private lazy var puzzleDataSource: PuzzleListDataSource = {
        let docsPath = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("puzzleData.json")
        let bundlePath = Bundle.main.url(forResource: "puzzleData",
                                         withExtension: "json")
        do {
            let data: Data
            if FileManager.default.fileExists(atPath: docsPath.absoluteString) &&
                UserDefaults.standard.bool(forKey: "hasGottenPuzzles") {
                data = try Data(contentsOf: docsPath)
            } else {
                guard let bundlePath = bundlePath else {
                    return PuzzleListDataSource(puzzles: [])
                }
                data = try Data(contentsOf: bundlePath)
                try data.write(to: docsPath)
                UserDefaults.standard.set(true, forKey: "hasGottenPuzzles")
            }
            let puzzleData = try JSONDecoder().decode([PuzzleClues].self,
                                                      from: data)
            return PuzzleListDataSource(puzzles: puzzleData)
       } catch {
            return PuzzleListDataSource(puzzles: [])
       }
    }()
    @IBOutlet weak var puzzleCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        puzzleCollectionView.dataSource = puzzleDataSource
        NotificationCenter.default.addObserver(self, selector: #selector(completePuzzle(_:)), name: .puzzleSolved, object: nil)
    }
    
    @objc private func completePuzzle(_ notif: Notification) {
        guard let index = notif.object as? Int else { return }
        puzzleDataSource.puzzles[index].isComplete = true
        puzzleCollectionView.reloadData()
        do {
            let data = try JSONEncoder().encode(puzzleDataSource.puzzles)
            let docsDir = FileManager.default.urls(for: .documentDirectory,
                                                  in: .userDomainMask)[0]
            let path = docsDir.appendingPathComponent("puzzleData.json")
            try data.write(to: path)
        } catch {
            alert(title: "Uh oh",
                  message: "An error ocurred. Your puzzle completion status has not been saved.",
                  dismissTitle: "Okay")
        }
    }
    
    @IBAction func resetPuzzleProgress(_ sender: Any) {
        let resetAction = UIAlertAction(
            title: "Reset",
            style: .destructive
        ) { _ in
            self.puzzleDataSource.puzzles.mapInPlace { $0.isComplete = false }
            do {
                
                let data = try JSONEncoder().encode(self.puzzleDataSource.puzzles)
                let docsDir = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask)[0]
                let path = docsDir.appendingPathComponent("puzzleData.json")
                try data.write(to: path)
                self.puzzleCollectionView.reloadData()
            } catch {
                self.alert(title: "Uh oh",
                           message: """
                           An error ocurred. Your puzzle completion status\
                           has not been saved.
                           """,
                           dismissTitle: "Okay")
            }
        }
        alert(title: "Reset puzzle progress?",
              message: "Are you sure you want all your progress to be reset?",
              actions: [
                UIAlertAction(title: "Cancel", style: .default),
                resetAction
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.solveSegueID {
            guard let destVC = segue.destination as? PuzzleViewController,
                let indexPath = puzzleCollectionView
                    .indexPathsForSelectedItems?.first else { return }
            destVC.puzzleClues = puzzleDataSource.puzzles[indexPath.item]
            destVC.puzzleIndex = indexPath.item
        }
    }
}
