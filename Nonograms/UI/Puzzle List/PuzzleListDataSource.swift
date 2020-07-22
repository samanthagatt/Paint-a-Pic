//
//  PuzzleListDataSource.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class PuzzleListDataSource: NSObject, UICollectionViewDataSource {
    private static let cellID = "puzzleCell"
    
    var puzzles: [PuzzleClues]
    
    init(puzzles: [PuzzleClues] = []) {
        self.puzzles = puzzles
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        puzzles.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Self.cellID,
            for: indexPath
        ) as? PuzzleListCell else { return UICollectionViewCell() }
        cell.numberLabel.text = "\(indexPath.item + 1)"
//        let puzzle = puzzles[indexPath.item]
//        cell.isComplete = puzzle.isComplete
        return cell
    }
}
