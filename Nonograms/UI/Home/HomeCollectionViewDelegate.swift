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
        // Get the view for the first header
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: indexPath) as? HomeCollectionViewHeader
        // Use this view to calculate the optimal size based on the collection view's width
        return CGSize(width: collectionView.frame.width,
                      height: headerView?.intrinsicContentSize.height ?? 300)
    }
}
