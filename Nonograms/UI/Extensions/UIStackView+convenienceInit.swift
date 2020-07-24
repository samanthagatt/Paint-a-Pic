//
//  UIStackView+convenienceInit.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/16/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIStackView {
    convenience init (
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 0,
        translatesMask: Bool = false
    ) {
        self.init()
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        translatesAutoresizingMaskIntoConstraints = translatesMask
    }
}
