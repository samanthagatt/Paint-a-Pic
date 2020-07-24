//
//  UIViewController+alert.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/15/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Presents alert controller
    /// - Parameters:
    ///     - title: Title of alert controller
    ///     - message: Message of alert controller
    ///     - preferredStyle: PreferredStyle of alert controller
    ///     - source: Source for popover controller when using action sheet on iPad
    ///     - animated: Alert controller is animated during presentation if `true`
    ///     - actions: Array of actions to be added to alert controller
    func alert(
        title: String?,
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .alert,
        source: UIView? = nil,
        animated: Bool = true,
        actions: [UIAlertAction]
    ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: preferredStyle)
        for action in actions {
            alert.addAction(action)
        }
        if preferredStyle == .actionSheet {
            let vc = alert.popoverPresentationController
            vc?.sourceView = source ?? view
            if source == nil {
                vc?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY,
                                        width: 0, height: 0)
                vc?.permittedArrowDirections = []
            }
        }
        present(alert, animated: true)
    }
    // Presents alert controller with only a dismiss action
    /// - Parameters:
    ///     - title: Title of alert controller
    ///     - message: Message of alert controller
    ///     - preferredStyle: PreferredStyle of alert controller
    ///     - source: Source for popover controller when using action sheet on iPad
    ///     - animated: Alert controller is animated during presentation if `true`
    ///     - dismissTitle: Title of dismiss action
    ///     - dismissStyle: Style of dismiss action
    func alert(
        title: String?,
        message: String? = nil,
        preferredStyle: UIAlertController.Style = .alert,
        source: UIView? = nil,
        animated: Bool = true,
        dismissTitle: String = "Dismiss",
        dismissStyle: UIAlertAction.Style = .default
    ) {
        alert(title: title,
              message: message,
              preferredStyle: preferredStyle,
              source: source,
              animated: animated,
              actions: [
                UIAlertAction(title: dismissTitle, style: dismissStyle)
        ])
    }
}
