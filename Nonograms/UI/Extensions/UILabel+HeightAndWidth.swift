//
//  UILabel+HeightAndWidth.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/20/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UILabel {
    func height(for width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeThatFits(size).height
    }
    func width(for height: CGFloat) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        return sizeThatFits(size).width
    }
}
