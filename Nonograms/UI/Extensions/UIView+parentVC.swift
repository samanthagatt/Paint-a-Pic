//
//  UIView+parentVC.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/22/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIView {
    func parentVC() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.parentVC()
        } else {
            return nil
        }
    }
}
