//
//  PuzzleListViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class PuzzleListViewController: UIViewController {
    private static let segueID = "puzzleSegue"
    private lazy var puzzleDataSource: PuzzleListDataSource = {
        do {
            guard let path = Bundle.main.url(forResource: "puzzleData",
                                            withExtension: "json") else {
                return PuzzleListDataSource(puzzles: [])
            }
            let data = try Data(contentsOf: path)
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.segueID {
            guard let destVC = segue.destination as? PuzzleViewController,
                let indexPath = puzzleCollectionView
                    .indexPathsForSelectedItems?.first else { return }
            destVC.puzzleRules = puzzleDataSource.puzzles[indexPath.item]
        }
    }
}
