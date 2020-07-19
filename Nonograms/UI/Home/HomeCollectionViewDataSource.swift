//
//  HomeCollectionViewDataSource.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class HomeCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var puzzles: [String: [PuzzleClues]] = [:]
    var selection: String = ""

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        17
        // puzzles[selection]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "collectionViewCell",
                                 for: indexPath)
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "collectionViewHeader",
            for: indexPath
        ) as? HomeCollectionViewHeader else { return UICollectionReusableView() }
        return header
    }
}

