//
//  HomeCollectionViewDataSource.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class HomeCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let collectionView = collectionView as? HomeCollectionView else {
            return 0
        }
        return collectionView.progressTracker
            .getPuzzles(for: collectionView.selection)?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let collectionView = collectionView as? HomeCollectionView,
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "collectionViewCell",
                                     for: indexPath) as? HomeCollectionViewCell
            else { return UICollectionViewCell() }
        cell.layer.cornerRadius = min(cell.frame.height, cell.frame.width) / 5
        cell.isLocked = collectionView.progressTracker
            .getState(for: indexPath.item, in: collectionView.selection) == .locked
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
