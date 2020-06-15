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
            // Update validator and row rules counts
            validator = PuzzleValidator(from: rules)
            maxRowRulesCount = rules.rowRules
                .reduce(0) { $0 < $1.count ? $1.count : $0 }
            maxColRulesCount = rules.colRules
                .reduce(0) { $0 < $1.count ? $1.count : $0 }
            // Setup puzzle again with updated rules
            setupPuzzle()
        }
    }
    /// The puzzle validator based off of the given` rules`
    private lazy var validator: PuzzleValidator =
        PuzzleValidator(from: rules)
    /// The number of rows needed to display grid and rules
    private var numRows: Int {
        validator.numRows + maxColRulesCount
    }
    /// The number of columns needed to display grid and rules
    private var numCols: Int {
        validator.numCols + maxRowRulesCount
    }
    /// Defaults to hard coded max in default rules
    private var maxRowRulesCount: Int = 2
    /// Defaults to hard coded max in default rules
    private var maxColRulesCount: Int = 3
    
    /// Padding desired between puzzle grid and rules
    @IBInspectable
    var rulesPadding: CGFloat = 16
    
    private lazy var gridStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    /// Reference to main stack view's width constraint
    private lazy var widthConstraint: NSLayoutConstraint = {
        gridStackView.widthAnchor.constraint(equalTo: widthAnchor)
    }()
    /// Reference to main stack view's height constraint
    private lazy var heightConstraint: NSLayoutConstraint = {
        gridStackView.heightAnchor.constraint(equalTo: heightAnchor)
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
        addSubview(gridStackView)
        setupPuzzle()
        // Center main stackview within view
        NSLayoutConstraint.activate([
            gridStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gridStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure puzzle view is still visible whenever view lays out its subviews
        // e.g. when the device rotates or any time the view's frame changes
        updateWidthHeightConstraints()
    }
    
    /// Setsup stack view (vertical) that holds each horizontal stack view to make the grid.
    private func setupGrid() {
        // Loop through the number of vertical rows desired
        for y in 0..<numRows {
            // Create horizontal stack view for each desired row
            /// Stack view containing all squares in the row
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            // Loop through number of horizontal rows desired (including rules)
            for x in 0..<numCols {
                
                // If in col or row rules area (top or left respectively)
                if y < maxColRulesCount || x < maxRowRulesCount {
                    let invisSquare = UIView()
                    invisSquare.backgroundColor = .clear
                    invisSquare
                        .translatesAutoresizingMaskIntoConstraints = false
                    // Make invis square a square
                    NSLayoutConstraint.activate([
                        invisSquare.widthAnchor
                            .constraint(equalTo: invisSquare.heightAnchor)
                    ])
                    
                    let colIndex = x - maxRowRulesCount
                    // If colIndex is __not__ negative,  we know x must be greater
                    // than maxRowRulesCount and y must be less than maxColRulesCount
                    // Meaning square is in col rules area (top right)
                    if colIndex >= 0 {
                        let colRule = rules.colRules[colIndex]
                        let ruleIndex = colRule.count - (maxColRulesCount - y)
                        if ruleIndex >= 0 {
                            // Add rule label to invisible square
                            let label = UILabel()
                            label.translatesAutoresizingMaskIntoConstraints = false
                            label.text = "\(colRule[ruleIndex])"
                            label.textAlignment = .center
                            invisSquare.addSubview(label)
                            NSLayoutConstraint.activate([
                                // Constrain invis square to be larger or equal to
                                // label size
                                invisSquare.widthAnchor
                                    .constraint(greaterThanOrEqualTo:
                                        label.widthAnchor),
                                invisSquare.heightAnchor
                                    .constraint(greaterThanOrEqualTo:
                                        label.heightAnchor),
                                // Constrain label to bottom center
                                label.bottomAnchor
                                    .constraint(equalTo:
                                        invisSquare.bottomAnchor),
                                label.centerXAnchor
                                    .constraint(equalTo:
                                        invisSquare.centerXAnchor)
                            ])
                        }
                    }
                    
                    let rowIndex = y - maxColRulesCount
                    // If rowIndex is __not__ negative,  we know y must be greater
                    // than maxColRulesCount and x must be less than maxRowRulesCount
                    // Meaning square is in row rules area (bottom left)
                    if rowIndex >= 0 {
                        let rowRule = rules.rowRules[rowIndex]
                        let ruleIndex = rowRule.count - (maxRowRulesCount - x)
                        if ruleIndex >= 0 {
                            // Add rule label to invisible square
                            let label = UILabel()
                            label.translatesAutoresizingMaskIntoConstraints = false
                            label.text = "\(rowRule[ruleIndex])"
                            label.textAlignment = .center
                            invisSquare.addSubview(label)
                            NSLayoutConstraint.activate([
                                // Constrain invis square to be larger or equal to
                                // label size
                                invisSquare.widthAnchor
                                    .constraint(greaterThanOrEqualTo:
                                        label.widthAnchor),
                                invisSquare.heightAnchor
                                    .constraint(greaterThanOrEqualTo:
                                        label.heightAnchor),
                                // Constrain label to right center
                                label.rightAnchor
                                    .constraint(equalTo:
                                        invisSquare.rightAnchor),
                                label.centerYAnchor
                                    .constraint(equalTo:
                                        invisSquare.centerYAnchor)
                            ])
                        }
                    }
                    
                    stackView.addArrangedSubview(invisSquare)
                    if x == maxRowRulesCount-1 {
                        stackView.setCustomSpacing(rulesPadding,
                                                   after: invisSquare)
                    }
                // Not in either rules area
                } else {
                    // Setup main grid
                    /// Add 1 so tags are 1 indexed (not 0 which is default for view tags)
                    let row = x - maxRowRulesCount + 1
                    let col = y - maxColRulesCount
                    /// Unique tag for each square
                    /// (from 1 to `validator.numRows` * `validator.numCols`)
                    let number = row + (validator.numRows * col)
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
            }
            // Add row view to grid stack view
            gridStackView.addArrangedSubview(stackView)
            if y == maxColRulesCount-1 {
                gridStackView.setCustomSpacing(rulesPadding, after: stackView)
            }
        }
    }
    
    private func setupPuzzle() {
        // Clear main  stack view's arranged subviews
        for subview in gridStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        setupGrid()
    }
    
    /// Determines which constraint needs to be activated
    /// in order for entire puzzle view to be visible within view
    private func getRulingConstraint() -> NSLayoutConstraint {
        let numSquaresInRow = CGFloat(numCols + maxRowRulesCount)
        let numSquaresInCol = CGFloat(numRows + maxColRulesCount)
        let maximumSquareWidth = frame.width / numSquaresInRow
        let maximumSqaureHeight = frame.height / numSquaresInCol
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
