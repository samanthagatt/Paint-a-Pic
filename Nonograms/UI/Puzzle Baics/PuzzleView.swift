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
    // MARK: - Properties
    // MARK: Rules and validation
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
            rowRules: [[1,1], [1,1,1], [1,1], [1,1], [1]],
            colRules: [[2], [1,1], [1,1], [1,1], [2]]
        ) {
        didSet {
            // Update validator and row rules counts
            // Overwrites old validator progress
            validator = PuzzleValidator(from: rules)
            // Setup puzzle again based on new rules
            setupPuzzle()
        }
    }
    /// The puzzle validator based off of the given` rules`
    /// - Warning: Progress will be overwritten when `rules` is changed/updated
    private lazy var validator: PuzzleValidator =
        PuzzleValidator(from: rules)
    
    // MARK: IB Inspectable
    /// Padding desired between puzzle grid and rules
    @IBInspectable
    var rulesToGridPadding: CGFloat = 12
    /// Padding desired between each rule in a given row or column
    @IBInspectable
    var innerRulesPadding: CGFloat = 8
    
    // MARK: Sub Views
    /// Column rules stack view (top rules)
    private var colRulesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .bottom
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()/// Row rules stack view (left rules)
    private var rowRulesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    /// Grid stack view
    private var gridStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: Constraint Refs
    /// Reference to grid stack view's width constraint
    private lazy var widthConstraint: NSLayoutConstraint = {
        gridStackView.widthAnchor.constraint(equalTo: widthAnchor)
    }()
    /// Reference to grid stack view's height constraint
    private lazy var heightConstraint: NSLayoutConstraint = {
        gridStackView.heightAnchor.constraint(equalTo: heightAnchor)
    }()
    /// Reference to grid stack view's center X constraint
    private lazy var centerXConstraint: NSLayoutConstraint = {
        gridStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
    }()
    /// Reference to grid stack view's center Y constraint
    private lazy var centerYConstraint: NSLayoutConstraint = {
        gridStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    /// Initializes new instance and sets `rules`.
    ///
    /// Use `puzzleValidity.sink()` to track when puzzle is solved.
    convenience init(_ rules: PuzzleRules) {
        self.init()
        self.rules = rules
    }
    
    /// Makes sure stack views are added to view and the puzzle grid is rendered
    private func sharedInit() {
        addSubview(gridStackView)
        addSubview(colRulesStackView)
        addSubview(rowRulesStackView)
        setupPuzzle()
        NSLayoutConstraint.activate([
            // Center grid in parent view
            centerXConstraint,
            centerYConstraint,
            
            // Constrain rowRules to left of grid
            rowRulesStackView.topAnchor
                .constraint(equalTo: gridStackView.topAnchor),
            rowRulesStackView.bottomAnchor
                .constraint(equalTo: gridStackView.bottomAnchor),
            rowRulesStackView.trailingAnchor
                .constraint(equalTo: gridStackView.leadingAnchor,
                            constant: -rulesToGridPadding),
            
            // Constrain colRules to top of grid
            colRulesStackView.leadingAnchor
                .constraint(equalTo: gridStackView.leadingAnchor),
            colRulesStackView.trailingAnchor
                .constraint(equalTo: gridStackView.trailingAnchor),
            colRulesStackView.bottomAnchor
                .constraint(equalTo: gridStackView.topAnchor,
                            constant: -rulesToGridPadding),
        ])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure puzzle view is still visible whenever view lays out its subviews
        // e.g. when the device rotates or any time the view's frame changes
        activateRulingConstraint()
    }
    /// Determines which constraint needs to be activated in order for entire puzzle
    /// to be visible within view, and updates constraints based off rules stack views
    private func getRulingConstraintAndSetConstants() -> NSLayoutConstraint {
        let maxSquareWidth = frame.width /
            CGFloat(validator.numCols)
        let maxSqaureHeight = frame.height /
            CGFloat(validator.numRows)
        
        let extraWidth = rowRulesStackView.frame.width +
            rulesToGridPadding
        let extraHeight = colRulesStackView.frame.height +
            rulesToGridPadding
        updateConstraintConstants(extraWidth: extraWidth,
                                  extraHeight: extraHeight)
        
        let maxWidth = maxSquareWidth + extraWidth
        let maxHeight = maxSqaureHeight + extraHeight
        
        // The smallest maximum length rules which constraint
        // to activate so the entire puzzle fits within the parent view
        return maxWidth < maxHeight ?
            widthConstraint : heightConstraint
        // If ratios are equal, either constraint will work
    }
    /// Updates width, height, and centering constraint constants based off of given extra width and height
    private func updateConstraintConstants(
        extraWidth: CGFloat,
        extraHeight: CGFloat
    ) {
        widthConstraint.constant = -extraWidth
        heightConstraint.constant = -extraHeight
        centerXConstraint.constant = extraWidth / 2
        centerYConstraint.constant = extraHeight / 2
    }
    /// Deactivates old constraints and activates ruling constraint so entire puzzle is visible within view
    private func activateRulingConstraint() {
        // Make sure old constraints are deactivated
        NSLayoutConstraint.deactivate([
            widthConstraint,
            heightConstraint
        ])
        // Activate ruling constraint
        NSLayoutConstraint.activate([
            getRulingConstraintAndSetConstants()
        ])
    }
    
    // MARK: - Puzzle Setup
    private func setupPuzzle() {
        setupRules(rowRulesStackView)
        setupRules(colRulesStackView)
        setupGrid()
    }
    func setupRules(_ rulesStackView: UIStackView) {
        for subView in rulesStackView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        let stackRules = rulesStackView == rowRulesStackView ?
            rules.rowRules : rules.colRules
        for rules in stackRules {
            let innerStackView = UIStackView()
            innerStackView.axis = rulesStackView == rowRulesStackView ?
                .horizontal : .vertical
            innerStackView.spacing = innerRulesPadding
            for rule in rules {
                let label = UILabel()
                label.text = "\(rule)"
                label.textAlignment = rulesStackView == rowRulesStackView ?
                    .right : .center
                innerStackView.addArrangedSubview(label)
            }
            rulesStackView.addArrangedSubview(innerStackView)
        }
    }
    /// Setsup stack view (vertical) that holds each horizontal stack view to make the grid.
    private func setupGrid() {
        for subview in gridStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        // Loop through the number of vertical rows desired
        for col in 0..<validator.numRows {
            // Create horizontal stack view for each desired row
            /// Stack view containing all squares in the row
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            // Loop through number of horizontal rows desired (including rules)
            for row in 1...validator.numCols {
                /// Add 1 so tags are 1 indexed (not 0 which is default for view tags)
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
            // Add row view to grid stack view
            gridStackView.addArrangedSubview(stackView)
        }
    }
}
