//
//  HomeCollectionViewFlowLayout.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

class HomeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(
        forBoundsChange newBounds: CGRect
    ) -> Bool { true }
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttrs = super.layoutAttributesForElements(in: rect)
        return layoutAttrs?.map { attrs in
            switch attrs.representedElementCategory {
            case .cell:
                return layoutAttributesForItem(at: attrs.indexPath) ?? attrs
            case .supplementaryView:
                guard let kind = attrs.representedElementKind else { return attrs }
                return layoutAttributesForSupplementaryView(
                    ofKind: kind,
                    at: attrs.indexPath
                ) ?? attrs
            case .decorationView:
                guard let kind = attrs.representedElementKind else { return attrs }
                return layoutAttributesForDecorationView(
                    ofKind: kind,
                    at: attrs.indexPath
                ) ?? attrs
            @unknown default:
                return attrs
            }
        }
    }
    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        let attrs = super
            .layoutAttributesForSupplementaryView(ofKind: elementKind,
                                                  at: indexPath)
        guard let offset = collectionView?.contentOffset,
            // Make sure user is overscrolling
            offset.y < 0,
            var frame = attrs?.frame,
            // Make sure it's the top header
            indexPath.section == 0
        // Else, make no changes
        else { return attrs }
        /// Amount overscrolled
        let diff = abs(offset.y)
        // Add the overscroll amount to the header height
        frame.size.height = max(0, frame.size.height + diff)
        // Make sure the header's origin is still at the very top of the collection view
        frame.origin.y = frame.minY - diff
        attrs?.frame = frame
        return attrs
    }
}
