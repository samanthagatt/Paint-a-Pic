//
//  UIViewController+alert.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/15/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style = .alert,
        animated: Bool = true,
        actions: [UIAlertAction]
    ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        for action in actions {
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
    func alert(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style = .alert,
        animated: Bool = true,
        dismissTitle: String = "Dismiss",
        dismissStyle: UIAlertAction.Style = .default
    ) {
        alert(title: title,
              message: message,
              preferredStyle: preferredStyle,
              animated: animated,
              actions: [
                UIAlertAction(title: dismissTitle, style: dismissStyle)
        ])
    }
}
