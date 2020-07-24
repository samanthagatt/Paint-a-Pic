//
//  HomeCollectionViewCell.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/22/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var isLocked: Bool = true {
        didSet {
            let systemName = isLocked ? "lock.fill" : "play.fill"
            imageView.image = UIImage(systemName: systemName)
            let alpha: CGFloat = isLocked ? 0.65 : 1
            backgroundColor = backgroundColor?.withAlphaComponent(alpha)
        }
    }
}
