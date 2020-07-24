//
//  HomeCollectionViewDelegate.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final
class HomeCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "collectionViewHeader",
            for: IndexPath(row: 0, section: section)
        ) as? HomeCollectionViewHeader
        return CGSize(width: collectionView.frame.width,
                      height: headerView?.intrinsicContentSize.height ?? 300)
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let collectionView = collectionView as? HomeCollectionView else {
            return
        }
        if collectionView.progressTracker
            .getState(for: indexPath.item,
                      in: collectionView.selection) != .locked {
            collectionView.parentVC()?.performSegue(withIdentifier: "showPuzzle",
                                                    sender: nil)
        }
    }
}
