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
    /// Emits `true` when puzzle is solved (each row and column
    /// meets the puzzle's `rules`)
    var puzzleValidity = PassthroughSubject<Bool, Never>()
    /// The rules of the puzzle. Used to create the grid and puzzle validator.
    ///
    /// Must be set (either in `viewDidLoad` of parent view controller if using IB, or
    /// using `.init(rules:)` programmatically) if not planning on using default value.
    var rules: PuzzleRules = PuzzleRules(
            rowRules: [[2, 1], [2], [2], [1], [2]],
            colRules: [[1, 1], [1, 1, 1], [3], [1], [1]]
        ) {
        didSet {
            validator = PuzzleValidator(from: rules)
            setupPuzzle()
        }
    }
    /// The puzzle validator based off of the given` rules`
    private lazy var validator: PuzzleValidator =
        PuzzleValidator(from: rules)
    /// The number of rows in the puzzle based off `rules`
    private var numRows: Int {
        validator.numRows
    }
    /// The number of columns in the puzzle based off `rules`
    private var numCols: Int {
        validator.numCols
    }
    
    /// Padding desired between puzzle grid and rules
    @IBInspectable
    var rulesPadding: CGFloat = 16
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = rulesPadding
        return stackView
    }()
    /// Reference to main stack view's width constraint
    private lazy var widthConstraint: NSLayoutConstraint = {
        mainStackView.widthAnchor.constraint(equalTo: widthAnchor)
    }()
    /// Reference to main stack view's height constraint
    private lazy var heightConstraint: NSLayoutConstraint = {
        mainStackView.heightAnchor.constraint(equalTo: heightAnchor)
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
        setupPuzzle()
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
    
    /// Makes stack view (vertical) that holds each horizontal stack view to make the grid.
    private func makeGrid() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
                    let isValid = self.validator
                        .toggle(square: squareTag)
                    self.puzzleValidity.send(isValid)
                }
                // Add square to horizontal stack view
                stackView.addArrangedSubview(square)
            }
            // Add row view to grid stack view
            stackView.addArrangedSubview(stackView)
        }
        return stackView
    }
    
    private func makeRules(axis: NSLayoutConstraint.Axis,
                           spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.distribution = .fillEqually
        
        let rulesArr = axis == .vertical ?
            rules.rowRules : rules.colRules
        
        for rule in rulesArr {
            let labelStack = UIStackView()
            labelStack.axis = axis == .vertical ?
                .horizontal : .vertical
            labelStack.spacing = spacing
            labelStack.alignment = axis == .vertical ?
                .trailing : .bottom
            for int in rule {
                let label = UILabel()
                label.text = "\(int)"
                labelStack.addArrangedSubview(label)
            }
            stackView.addArrangedSubview(labelStack)
        }
        return stackView
    }
    
    private func setupPuzzle() {
        // Clear main  stack view's arranged subviews
        for subview in mainStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        let ruleSpacing: CGFloat = 6
        let topRules = makeRules(axis: .horizontal, spacing: ruleSpacing)
        let leftRules = makeRules(axis: .horizontal, spacing: ruleSpacing)
        leftRules.setContentCompressionResistancePriority(.defaultHigh,
                                                          for: .horizontal)
        leftRules.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let top = UIStackView()
        top.axis = .horizontal
        top.setContentCompressionResistancePriority(.defaultHigh,
                                                    for: .vertical)
        top.setContentHuggingPriority(.defaultHigh, for: .vertical)
        let blankSquare = UIView()
        NSLayoutConstraint.activate([
            blankSquare.heightAnchor
                .constraint(equalTo: blankSquare.widthAnchor)
        ])
        top.addArrangedSubview(blankSquare)
        top.addArrangedSubview(topRules)
        
        let bottom = UIStackView()
        bottom.axis = .horizontal
        bottom.spacing = ruleSpacing
        bottom.addArrangedSubview(leftRules)
        bottom.addArrangedSubview(makeGrid())
        
        mainStackView.addArrangedSubview(top)
        mainStackView.addArrangedSubview(bottom)
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
