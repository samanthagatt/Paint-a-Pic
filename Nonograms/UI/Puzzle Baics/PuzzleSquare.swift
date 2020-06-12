//
//  PuzzleSquare.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/11/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

@IBDesignable
final class PuzzleSquare: UIView {
    /// Color to assign background when square is **not** filled
    private var emptyColor: UIColor = .clear
    /// Color to assign background when square is filled
    private var filledColor: UIColor = .black
    /// `Bool` representing if the user has filled in the square or not
    private(set) var isFilled: Bool = false {
        didSet { setBackground() }
    }
    /// Closure called when square view is tapped
    /// - Returns: Success of closure as a `Bool`
    var wasTapped: (Int) -> Void = { _ in }
    
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
        isFilled: Bool = false,
        wasTapped: @escaping (Int) -> Void = { _ in }
    ) {
        self.init()
        self.tag = tag
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
        wasTapped(tag)
        isFilled.toggle()
    }
    
    /// Sets background color of square based off whether it is filled or not
    private func setBackground() {
        backgroundColor = isFilled ? filledColor : emptyColor
    }
}
