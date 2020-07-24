//
//  UIViewController+setBackNavButton.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/15/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Overrides default back button to allow for code to be run before navigating backwards
    /// - Note: You must manually navigate backwards in the selector
    func setBackNavButton(selector: Selector) {
        let backButton = BackNavButton()
        backButton.addTarget(self,
                             action: selector,
                             for: .touchUpInside)
        let backBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
    }
}
