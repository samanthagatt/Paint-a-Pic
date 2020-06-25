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
        didSet {
            scaleFont()
        }
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

enum TextStyle: String {
    case body, callout, caption1, caption2, footnote,
        headline, subheadline, largeTitle, title1,
        title2, title3
    func toUIFontTextStyle() -> UIFont.TextStyle {
        switch self {
        case .body: return .body
        case .callout: return .callout
        case .caption1: return .caption1
        case .caption2: return .caption2
        case .footnote: return .footnote
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .largeTitle: return .largeTitle
        case .title1: return .title1
        case .title2: return .title2
        case .title3: return .title3
        }
    }
}
