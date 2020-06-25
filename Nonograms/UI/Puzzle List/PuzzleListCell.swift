//
//  PuzzleListCell.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class PuzzleListCell: UICollectionViewCell {
    var isComplete: Bool = false {
        didSet {
            if isComplete {
                numberLabel.isHidden = true
                checkmarkImageView.isHidden = false
            } else {
                numberLabel.isHidden = false
                checkmarkImageView.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var numberLabel: AccessibleLabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    private func sharedInit() {
        contentView.layer.borderColor = UIColor.label.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 5
    }
}
