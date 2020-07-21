//
//  HomeCollectionViewHeader.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/18/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class HomeCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var coloredView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectLevelLabel: AccessibleLabel!
    @IBOutlet weak var selectionButton: SquovalButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPaddingConstraint: NSLayoutConstraint!
    
    private var startingImageHeight: CGFloat = 180
    
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: coloredView.frame.width,
            height: startingImageHeight + abs(spacingConstraint.constant) +
                max(selectLevelLabel.height(for: selectLevelLabel.frame.width),
                    stackView.frame.height) +
                abs(bottomPaddingConstraint.constant)
        )
    }
    
    @IBAction func play(_ sender: Any) {
        
    }
    @IBAction func openMenu(_ sender: Any) {
        
    }
}
