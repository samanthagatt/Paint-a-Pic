//
//  PuzzleView.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit
import Combine

/// Displays puzzle and is interactive.
///
/// When user taps on a square it gets filled in
@IBDesignable
final class PuzzleView: UIView {
    /// A passthrough subject from `Combine` that emits a bool representing
    /// if the puzzle is valid every time a square is tapped.
    ///
    /// Will always emit `false` if `rules` is not set.
    /// Emits `true` when puzzle is solved (each row and column
    /// meets the puzzle's `rules`)
    var puzzleValidity = PassthroughSubject<Bool, Never>()
    /// The rules of the puzzle. Used to create the grid and puzzle validator.
    ///
    /// Must be set (either in `viewDidLoad` of parent view controller if using IB,
    /// or using `.init(rules:)` programmatically) to gain validation functionality
    var rules: PuzzleRules? {
        didSet {
            guard let rules = rules else { return }
            validator = PuzzleValidator(from: rules)
            setupGrid()
        }
    }
    /// The puzzle validator based off of the given` rules`
    private var validator: PuzzleValidator?
    /// The number of rows in the puzzle based off `rules`. Defaults to `10`
    private var numRows: Int {
        validator?.numRows ?? 10
    }
    /// The number of columns in the puzzle based off `rules`. Defaults to `10`
    private var numCols: Int {
        validator?.numCols ?? 10
    }
    
    /// Padding desired on both sides of puzzle
    @IBInspectable
    var horizontalPadding: CGFloat = 0 {
        // Needs to update width constraint when updated in IB
        didSet {
            widthConstraint.constant = -horizontalPadding * 2
        }
    }
    /// Padding desired on the top and bottom of puzzle
    @IBInspectable
    var verticalPadding: CGFloat = 0 {
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
    /// Initializes new instance and sets `rules`. `sink` `puzzleValidity` to
    /// subscribe to changes in puzzle validity.
    convenience init(_ rules: PuzzleRules) {
        self.init()
        self.rules = rules
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
        for col in 0..<numCols {
            // Create horizontal stack view for each desired row
            /// Stack view containing all squares in the row
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            // Loop through number of horizontal rows desired
            for row in 1...numRows {
                /// Unique tag for each square (from 1 to `numRows` * `numCols`)
                let number = row + (numRows * col)
                let square = PuzzleSquare(tag: number) {
                    [weak self] squareTag in
                    guard let self = self else { return }
                    let isValid = self.validator?
                        .toggle(square: squareTag) ?? false
                    self.puzzleValidity.send(isValid)
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
