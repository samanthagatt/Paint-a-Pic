//
//  PuzzleView.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

@IBDesignable
final class PuzzleView: UIView {
    
    /// Number of squares in each row
    @IBInspectable
    private var numRows: Int = 10 {
        didSet {
            // Number of rows can't be less than 5
            if numRows < 5 { numRows = 5 }
            setupGrid()
        }
    }
    /// Number of squares in each column
    @IBInspectable
    private var numCols: Int = 10 {
        didSet {
            // Number of columns can't be less than 5
            if numCols < 5 { numCols = 5 }
            setupGrid()
        }
    }
    /// Padding desired on both sides of puzzle
    @IBInspectable
    private var horizontalPadding: CGFloat = 0 {
        // Needs to update width constraint when updated in IB
        didSet {
            widthConstraint.constant = -horizontalPadding * 2
        }
    }
    /// Padding desired on the top and bottom of puzzle
    @IBInspectable
    private var verticalPadding: CGFloat = 0 {
        // Needs to update height constraint when updated in IB
        didSet {
            heightConstraint.constant = -verticalPadding * 2
        }
    }
    
    /// Main stack view (vertical). Will hold each horizontal stack view to make a grid.
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    /// Reference to main stack view's width constraint
    private lazy var widthConstraint: NSLayoutConstraint = {
        mainStackView.widthAnchor
            .constraint(equalTo: widthAnchor, constant: -horizontalPadding)
    }()
    /// Reference to main stack view's height constraint
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
    
    /// Makes sure main stack view is added to view and the puzzle grid is rendered
    private func sharedInit() {
        addSubview(mainStackView)
        setupGrid()
        // Center main stackview within view
        NSLayoutConstraint.activate([
            mainStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure puzzle view is still visible whenever view lays out its subviews
        // e.g. when the device rotates or any time the view's frame changes
        updateWidthHeightConstraints()
    }
    
    /// Renders puzzle grid
    /// - Note: Clears old grid before adding new one
    private func setupGrid() {
        // Clear main stack view's arranged subviews
        for subview in mainStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        // Loop through the number of vertical rows desired
        for i in 0..<numCols {
            // Create horizontal stack view for each desired row
            /// Stack view containing all squares in the row
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            // Loop through number of horizontal rows desired
            for j in 1...numRows {
                /// Unique tag for each square (from 1 to `numRows` * `numCols`)
                let number = j + (numRows * i)
                let square = PuzzleSquare(tag: number) { tag in
                    print(tag)
                    return true
                }
                // Add square to horizontal stack view
                stackView.addArrangedSubview(square)
            }
            // Add row view to main stack view
            mainStackView.addArrangedSubview(stackView)
        }
    }
    
    /// Determines which constraint needs to be activated
    /// in order for entire puzzle view to be visible within view
    private func getRulingConstraint() -> NSLayoutConstraint {
        let maximumSquareWidth = frame.width / CGFloat(numRows)
        let maximumSqaureHeight = frame.height / CGFloat(numCols)
        // The smallest maximum length of a square rules which constraint
        // to activate so the puzzle fits within the parent view
        return maximumSquareWidth < maximumSqaureHeight ?
            widthConstraint : heightConstraint
        // If ratios are equal, either constraint will work
    }
    
    /// Deactivates old constraints and activates ruling constraint
    /// so entire main stack view is visible within parent view
    private func updateWidthHeightConstraints() {
        // Make sure old constraints are deactivated
        NSLayoutConstraint.deactivate([
            widthConstraint,
            heightConstraint
        ])
        // Activate ruling constraint
        NSLayoutConstraint.activate([
            getRulingConstraint()
        ])
    }
}
