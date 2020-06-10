//
//  PuzzleView.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

@IBDesignable
class PuzzleView: UIView {
    
    /// Number of squares horizontally
    @IBInspectable
    var horizontalRows: Int = 10 {
        didSet {
            if horizontalRows < 5 {
                horizontalRows = 5
            }
            setupGrid()
        }
    }
    /// Number of squares vertically
    @IBInspectable
    var verticalRows: Int = 10 {
        didSet {
            if verticalRows < 5 {
                verticalRows = 5
            }
            setupGrid()
        }
    }
    @IBInspectable
    var horizontalPadding: CGFloat = 0 {
        didSet {
            NSLayoutConstraint.deactivate([widthConstraint])
            widthConstraint = mainStackView.widthAnchor
                .constraint(equalTo: widthAnchor,
                            constant: -horizontalPadding)
            NSLayoutConstraint.activate([getSmallestConstraint()])
        }
    }
    @IBInspectable
    var verticalPadding: CGFloat = 0 {
        didSet {
            NSLayoutConstraint.deactivate([heightConstraint])
            heightConstraint = mainStackView.heightAnchor
                .constraint(equalTo: heightAnchor,
                            constant: -verticalPadding)
            NSLayoutConstraint.activate([getSmallestConstraint()])
        }
    }
    
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        // stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var widthConstraint: NSLayoutConstraint = {
        mainStackView.widthAnchor
            .constraint(equalTo: widthAnchor, constant: -horizontalPadding)
    }()
    private lazy var heightConstraint: NSLayoutConstraint = {
        mainStackView.heightAnchor
            .constraint(equalTo: heightAnchor, constant: -verticalPadding)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.deactivate([
            widthConstraint,
            heightConstraint
        ])
        let smallestConstraint = getSmallestConstraint()
        NSLayoutConstraint.activate([
            smallestConstraint
        ])
    }
    
    private func sharedInit() {
        addSubview(mainStackView)
        setupGrid()
    }
    
    private func setupGrid() {
        for subview in mainStackView.arrangedSubviews {
            mainStackView.removeArrangedSubview(subview)
        }
        for i in 1...verticalRows {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            for j in 1...horizontalRows {
                let square = UIView()
                // Visual setup
                square.tag = i + (horizontalRows * j)
                square.backgroundColor = .clear
                square.layer.borderColor = UIColor.black.cgColor
                square.layer.borderWidth = 1
                
                // Gesture setup
                
                stackView.addArrangedSubview(square)
                square.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    square.widthAnchor
                        .constraint(equalTo: square.heightAnchor)
                ])
            }
            mainStackView.addArrangedSubview(stackView)
        }
        
        NSLayoutConstraint.activate([
            // Centers stackview within superview
            mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            getSmallestConstraint()
        ])
    }
    
    private func getSmallestConstraint() -> NSLayoutConstraint {
        frame.width < frame.height ?
            widthConstraint : heightConstraint
    }
}
