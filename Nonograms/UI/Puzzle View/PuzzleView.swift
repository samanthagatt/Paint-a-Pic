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
    /// using `.init(rules:)` programmatically) if `isForSolving` is true.
    var rules: PuzzleRules = PuzzleRules(
        name: "",
        rowRules: [[], [], [], [], []],
        colRules: [[], [], [], [], []]
    ) {
        didSet {
            // Makes sure name isn't the only thing that's changed
            guard rules.rowRules != oldValue.rowRules ||
                rules.colRules != oldValue.colRules else {
                maker.name = rules.name
                return
            }
            // Update validator
            // Overwrites old validator progress
            validator = PuzzleValidator(from: rules)
            // Update maker
            maker = PuzzleMaker(name: rules.name,
                                numRows: rules.rowRules.count,
                                numCols: rules.colRules.count)
            // Setup puzzle again based on new rules
            setupPuzzle()
        }
    }
    /// The puzzle validator based off of the given` rules`
    /// - Warning: Progress will be overwritten when `rules` is changed/updated
    private lazy var validator: PuzzleValidator =
        PuzzleValidator(from: rules)
    var fillMode: PuzzleFillMode = .fill
    private lazy var maker: PuzzleMaker = PuzzleMaker(
        name: rules.name,
        numRows: rules.rowRules.count,
        numCols: rules.colRules.count
    )
    
    // MARK: IB Inspectable
    @IBInspectable var isForSolving: Bool = true
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
    }()
    /// Row rules stack view (left rules)
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
        
        /// Width of row rules and padding between rules and puzzle
        let rowRulesWidth = rowRulesStackView.frame.width +
            rulesToGridPadding
        /// Height of column rules and padding between rules and puzzle
        let colRulesHeight = colRulesStackView.frame.height +
            rulesToGridPadding
        updateConstraintConstants(rowRulesWidth, colRulesHeight)
        
        // Only one length constraint should be activated at a time
        // Stack view will determine size of the other length
        // Deactivate old constraints
        NSLayoutConstraint.deactivate([
            widthConstraint,
            heightConstraint
        ])
        // Activate ruling constraint so entire puzzle is visible within view
        NSLayoutConstraint.activate([
            getRulingConstraint(rowRulesWidth, colRulesHeight)
        ])
    }
    /// Determines which constraint needs to be activated in order for entire puzzle to be visible
    /// - Parameter rowRulesWidth: The width of the row rules stack view
    /// - Parameter colRulesHeight: The height of the column rules stack view
    private func getRulingConstraint(
        _ rowRulesWidth: CGFloat,
        _ colRulesHeight: CGFloat
    ) -> NSLayoutConstraint {
        /// Maximum width of a single square depending on what's left over after rules are rendered
        let maxSquareWidth = (frame.width - rowRulesWidth) /
            CGFloat(rules.colRules.count)
        /// Maximum height of a single square depending on what's left over after rules are rendered
        let maxSqaureHeight = (frame.height - colRulesHeight) /
            CGFloat(rules.rowRules.count)
        // The smallest maximum length rules which constraint to activate
        // so the entire puzzle fits within the parent view
        return maxSquareWidth < maxSqaureHeight ?
            widthConstraint : heightConstraint
        // If max lengths happen to be equal, either constraint will work
    }
    /// Updates width, height, and centering constraint constants based off of given width and height of rules
    /// - Parameter rowRulesWidth: The width of the row rules stack view
    /// - Parameter colRulesHeight: The height of the column rules stack view
    private func updateConstraintConstants(
        _ rowRulesWidth: CGFloat,
        _ colRulesHeight: CGFloat
    ) {
        // Leave room for rules to be displayed
        widthConstraint.constant = -rowRulesWidth
        heightConstraint.constant = -colRulesHeight
        // Center grid AND rules horizontally and vertically
        centerXConstraint.constant = rowRulesWidth / 2
        centerYConstraint.constant = colRulesHeight / 2
    }
    
    // MARK: - Puzzle Setup
    /// Sets up puzzle. Removes old rules and grid before building and rendering them again.
    ///
    /// Should be called after `rules` changes
    private func setupPuzzle() {
        setupRules(rowRulesStackView)
        setupRules(colRulesStackView)
        setupGrid()
    }
    private func setupRules(_ rulesStackView: UIStackView) {
        // Delete old rules
        for subView in rulesStackView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        // Get desired array of rule arrays
        let stackRules = rulesStackView == rowRulesStackView ?
            rules.rowRules : rules.colRules
        // For each array of rules in desired rules array
        for rules in stackRules {
            // Create stack view to hold every rule
            let innerStackView = UIStackView()
            // Axis should be horizontal for row rules and vertically for column rules
            innerStackView.axis = rulesStackView == rowRulesStackView ?
                .horizontal : .vertical
            innerStackView.spacing = innerRulesPadding
            for rule in rules {
                let label = UILabel()
                label.text = "\(rule)"
                // Text alignment should be right for row rules and center for column rules
                // so they line up nicely against the grid
                label.textAlignment = rulesStackView == rowRulesStackView ?
                    .right : .center
                innerStackView.addArrangedSubview(label)
            }
            rulesStackView.addArrangedSubview(innerStackView)
        }
    }
    /// Setsup stack view (vertical) that holds each horizontal stack view to make the grid.
    private func setupGrid() {
        // Delete old grid
        for subview in gridStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        // Loop through the number of vertical rows desired
        for col in 0..<rules.rowRules.count {
            // Create horizontal stack view for each desired row
            /// Stack view containing all squares in the row
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            // Loop through number of horizontal rows desired (including rules)
            for row in 1...rules.colRules.count {
                /// Add 1 so tags are 1 indexed (not 0 which is default for view tags)
                /// Unique tag for each square
                /// (from 1 to `rules.rowRules.count` * `rules.colRules.count`)
                let number = row + (rules.colRules.count * col)
                let square = PuzzleSquare(tag: number) {
                    [weak self] squareTag, fillState in
                    guard let self = self else { return .fill }
                    if self.isForSolving {
                        if self.fillMode == .fill && fillState != .exed {
                            let isValid = self.validator
                                .toggle(square: squareTag)
                            self.puzzleValidity.send(isValid)
                        }
                    } else {
                        self.maker.filled.toggle(squareTag)
                    }
                    return self.fillMode
                }
                // Add square to horizontal stack view
                stackView.addArrangedSubview(square)
            }
            // Add row view to grid stack view
            gridStackView.addArrangedSubview(stackView)
        }
    }
    
    func filledSquaresAsRules() -> PuzzleRules {
        return maker.getRules()
    }
}
