//
//  TextStyle.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/25/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

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
