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
    var wasTapped: (Int) -> Bool = { _ in true }
    
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
        wasTapped: @escaping (Int) -> Bool = { _ in true }
    ) {
        self.init()
        self.tag = tag
        self.wasTapped = wasTapped
    }
    private func sharedInit() {
        setBackground()
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
        // Make sure wasTapped was successful
        guard wasTapped(tag) else { return }
        // Only toggle isFilled if wasTapped succeeded
        isFilled.toggle()
    }
    
    private func setBackground() {
        backgroundColor = isFilled ? filledColor : emptyColor
    }
}
