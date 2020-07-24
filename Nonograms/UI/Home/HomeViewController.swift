//
//  HomeViewController.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: HomeCollectionView!
    
    private let dataSource = HomeCollectionViewDataSource()
    private let delegate = HomeCollectionViewDelegate()
    /// Set of all subscriptions. Each will be canceled on deallocation.
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = delegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showPuzzle",
            let destVC = segue.destination as? PuzzleViewController,
            let indexPath = collectionView
                .indexPathsForSelectedItems?.first else { return }
        destVC.puzzles = collectionView.progressTracker
            .getPuzzles(for: collectionView.selection)
        destVC.puzzleIndex = indexPath.item
        destVC.shouldShowNext = { [weak self] in
            guard let self = self,
                let i = destVC.puzzleIndex else { return false }
            let puzzleState = self.collectionView.progressTracker
                .getState(for: i, in: self.collectionView.selection)
            return puzzleState == .unlocked(true)
        }
        destVC.puzzleView.puzzleValidity.sink { [weak self] isValid in
            if isValid {
                guard let i = destVC.puzzleIndex, let self = self else { return }
                self.collectionView.progressTracker
                    .complete(i, in: self.collectionView.selection)
            }
        }.store(in: &subscriptions)
    }
}
