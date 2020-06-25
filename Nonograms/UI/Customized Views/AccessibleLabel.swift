//
//  Label.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/25/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

@IBDesignable class AccessibleLabel: UILabel {
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
        startingFont = font
        scaleFont()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        startingFont = font
        scaleFont()
    }
    
    func scaleFont() {
        font = UIFontMetrics(forTextStyle: textStyle.toUIFontTextStyle())
            .scaledFont(for: startingFont)
    }
}
