//
//  UIView+addSubViews.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/16/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIView {
    /// Adds views (in order) to the end of the receiver’s list of subviews.
    func addSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addSubview(subview)
        }
    }
    /// Adds views (in order) to the end of the receiver’s list of subviews.
    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            addSubview(subview)
        }
    }
}

extension UIStackView {
    /// Adds a views (in order) to the end of the arrangedSubviews array.
    func addArrangedSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
    /// Adds a views (in order) to the end of the arrangedSubviews array.
    func addArrangedSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
}
