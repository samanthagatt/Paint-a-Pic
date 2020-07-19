//
//  MonoLabel.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/19/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

@IBDesignable
final class MonoLabel: AccessibleLabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        font = .monospacedSystemFont(ofSize: font.pointSize, weight: font.weight)
    }
}

extension UIFont {
    var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }

    private var traits: [UIFontDescriptor.TraitKey: Any] {
        return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
            ?? [:]
    }
}
