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
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPaddingConstraint: NSLayoutConstraint!
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: .infinity,
               height: coloredView.frame.height +
                    spacingConstraint.constant +
                    stackView.frame.height +
                    bottomPaddingConstraint.constant)
    }
}
