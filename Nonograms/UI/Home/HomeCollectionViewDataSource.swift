//
//  HomeCollectionViewDataSource.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class HomeCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    private var puzzleLoader = PuzzleLoader()
    private var selection = 0
    
    func changeSelection(to newSelection: Int) {
        selection = newSelection
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        puzzleLoader.getPuzzles(for: selection)?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "collectionViewCell",
                                 for: indexPath)
        cell.layer.cornerRadius = min(cell.frame.height, cell.frame.width) / 5
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "collectionViewHeader",
            for: indexPath
        )
        header.clipsToBounds = false
        return header
    }
}
