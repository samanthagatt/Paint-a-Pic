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
    @IBOutlet weak var selectionButton: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var allCorners: Bool = true
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundSelectionButton()
    }
    
    @IBAction func play(_ sender: Any) {
        
    }
    @IBAction func toggleMenu(_ sender: Any) {
        let shouldHide = !selectionTableView.isHidden
        tableViewHeightConstraint.constant = shouldHide ? 128 : 0
        selectionTableView.isHidden = false
        if !shouldHide { allCorners = shouldHide }
        layoutIfNeeded()
        tableViewHeightConstraint.constant = shouldHide ? 0 : 128
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        }, completion: { _ in
            if shouldHide {
                self.selectionTableView.isHidden = true
                self.allCorners = shouldHide
                self.roundSelectionButton()
            }
        })
    }
    
    private func roundSelectionButton() {
        selectionButton.layer.maskedCorners = allCorners ?
            [.layerMinXMinYCorner, .layerMaxXMinYCorner,
             .layerMinXMaxYCorner, .layerMaxXMaxYCorner] :
            [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        selectionButton.layer.cornerRadius = min(selectionButton.frame.width,
            selectionButton.frame.height) / 4
    }
}
