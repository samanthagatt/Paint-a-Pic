//
//  UIView+asImage.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/16/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIView {
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { context in
                layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
    }
}
