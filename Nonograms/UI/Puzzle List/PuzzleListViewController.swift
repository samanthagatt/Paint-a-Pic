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
    private lazy var docsPath: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("puzzleData.json")
    }()
    private lazy var bundlePath: URL? = {
        Bundle.main.url(forResource: "puzzleData", withExtension: "json")
    }()
    private lazy var puzzleDataSource: PuzzleListDataSource = {
        do {
            let data: Data
            if try docsPath.checkResourceIsReachable() &&
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
            let puzzleData = try JSONDecoder().decode([PuzzleRules].self,
                                                      from: data)
            return PuzzleListDataSource(puzzles: puzzleData)
       } catch {
            print("Error! \(error)")
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
            print("Oops! ERROR: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.solveSegueID {
            guard let destVC = segue.destination as? PuzzleViewController,
                let indexPath = puzzleCollectionView
                    .indexPathsForSelectedItems?.first else { return }
            destVC.puzzleRules = puzzleDataSource.puzzles[indexPath.item]
            destVC.puzzleIndex = indexPath.item
        } else if segue.identifier == Self.createSegueID {
            guard let destVC = segue.destination as?
                CreatePuzzleViewController else { return }
            destVC.puzzleData = puzzleDataSource.puzzles
        }
    }
}
