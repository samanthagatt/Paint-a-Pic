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
    private let puzzleDataSource = PuzzleListDataSource(puzzles: puzzleData)
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
            destVC.puzzleRule = puzzleDataSource.puzzles[indexPath.item]
        }
    }
}
