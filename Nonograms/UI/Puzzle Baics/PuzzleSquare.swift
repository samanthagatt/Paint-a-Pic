//
//  PuzzleSquare.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

enum PuzzleFillMode {
    case ex, fill
}
enum PuzzleSquareFillState {
    case filled, empty, exed
    mutating func setNewState(for mode: PuzzleFillMode) {
        switch mode {
        case .fill: switch self {
            case .filled: self = .empty
            case .empty: self = .filled
            case .exed: self = .exed
            }
        case .ex: switch self {
            case .empty: self = .exed
            case .exed: self = .empty
            case .filled: self = .filled
            }
        }
    }
}

@IBDesignable
final class PuzzleSquare: UIView {
    
    /// Color to assign background when square is **not** filled
    private var emptyColor: UIColor = .white
    /// Color to assign background when square is filled
    private var filledColor: UIColor = .black
    /// Enum representing if the square is filled in, empty, or marked with an `x`
    private(set) var fillState: PuzzleSquareFillState = .empty {
        didSet { updateFill() }
    }
    /// Closure called when square view is tapped
    /// - Returns: Success of closure as a `Bool`
    var wasTapped: (Int, PuzzleSquareFillState)
        -> PuzzleFillMode = { _,_ in .fill }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    convenience init(
        tag: Int,
        emptyColor: UIColor = .clear,
        filledColor: UIColor = .black,
        wasTapped: @escaping (Int, PuzzleSquareFillState)
            -> PuzzleFillMode = { _,_ in .fill }
    ) {
        self.init()
        self.tag = tag
        self.emptyColor = emptyColor
        self.filledColor = filledColor
        self.wasTapped = wasTapped
    }
    /// Handles setting up view when initialized
    private func sharedInit() {
        backgroundColor = emptyColor
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(_:))
        )
        addGestureRecognizer(tapGesture)
        
        // Constrain square view
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Make square view a square
            widthAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    /// Toggles background of view that was tapped
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let mode = wasTapped(tag, fillState)
        fillState.setNewState(for: mode)
    }
    private func updateFill() {
        switch fillState {
        case .empty: backgroundColor = emptyColor
        case .filled: backgroundColor = filledColor
        case .exed: backgroundColor = .lightGray
        }
    }
}
