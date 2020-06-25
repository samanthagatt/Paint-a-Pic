//
//  AccessibleButton.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/25/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

@IBDesignable class AccessibleButton: UIButton {
    var startingFont: UIFont = .preferredFont(forTextStyle: .body)
    var textStyle: TextStyle = .body {
        didSet { scaleFont() }
    }
    @IBInspectable var fontTextStyle: String {
        get { textStyle.rawValue }
        set {
            textStyle = TextStyle(rawValue: newValue) ?? .body
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    private func sharedInit() {
        startingFont = titleLabel?.font ?? .preferredFont(forTextStyle: .body)
        scaleFont()
    }
    
    func scaleFont() {
        titleLabel?.font = UIFontMetrics(
            forTextStyle: textStyle.toUIFontTextStyle()
        ).scaledFont(for: startingFont)
    }
}
