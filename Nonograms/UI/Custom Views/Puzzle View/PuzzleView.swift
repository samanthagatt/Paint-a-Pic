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
    var image: UIImage? {
        gridStackView.asImage()
    }
    // MARK: Clues and validation
    /// A passthrough subject from `Combine` that emits a bool representing
    /// if the puzzle is valid every time a square is tapped.
    ///
    /// Emits `true` when puzzle is solved (each row and column
    /// meets the puzzle's `clues`)
    var puzzleValidity = PassthroughSubject<Bool, Never>()
    var squaresTooSmall = PassthroughSubject<Bool, Never>()
    /// The clues for the puzzle. Used to create the grid and puzzle validator.
    ///
    /// Must be set (either in `viewDidLoad` of parent view controller if using IB, or
    /// using `.init(clues:)` programmatically) if `isForSolving` is true.
    var clues: PuzzleClues = PuzzleClues(
        name: "",
        rowClues: [[], [], [], [], []],
        colClues: [[], [], [], [], []]
    ) {
        didSet {
            // Makes sure name isn't the only thing that's changed
            guard clues.rowClues != oldValue.rowClues ||
                clues.colClues != oldValue.colClues else {
                    // Update name
                    maker.name = clues.name
                    return
            }
            // Update validator
            // Overwrites old validator progress
            validator = PuzzleValidator(from: clues)
            // Update maker
            maker = PuzzleMaker(name: clues.name,
                                numRows: clues.rowClues.count,
                                numCols: clues.colClues.count)
            // Setup puzzle again based on new clues
            setupPuzzle()
        }
    }
    /// The puzzle validator based off of the given` clues`
    /// - Warning: Progress will be overwritten when `clues` is changed/updated
    private lazy var validator: PuzzleValidator =
        PuzzleValidator(from: clues)
    var fillMode: PuzzleFillMode = .fill
    private lazy var maker: PuzzleMaker = PuzzleMaker(
        name: clues.name,
        numRows: clues.rowClues.count,
        numCols: clues.colClues.count
    )
    private var referenceSquare: UIView?
    
    // MARK: IB Inspectable
    @IBInspectable var isForSolving: Bool = true
    /// Padding desired between puzzle grid and clues
    @IBInspectable
    var cluesToGridPadding: CGFloat = 12
    /// Padding desired between each clue in a given row or column
    @IBInspectable
    var innerCluesPadding: CGFloat = 8
    
    // MARK: Sub Views
    /// Column clues stack view (top clues)
    private var colCluesStackView = UIStackView(axis: .horizontal,
                                                distribution: .fillEqually,
                                                alignment: .bottom)
    /// Row clues stack view (left clues)
    private var rowCluesStackView = UIStackView(axis: .vertical,
                                                distribution: .fillEqually)
    /// Grid stack view
    private var gridStackView = UIStackView(axis: .vertical)
    
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
    /// Initializes new instance and sets `clues`.
    ///
    /// Use `puzzleValidity.sink()` to track when puzzle is solved.
    convenience init(_ clues: PuzzleClues) {
        self.init()
        self.clues = clues
    }
    
    /// Makes sure stack views are added to view and the puzzle grid is rendered
    private func sharedInit() {
        addSubviews(gridStackView, colCluesStackView, rowCluesStackView)
        setupPuzzle()
        NSLayoutConstraint.activate([
            // Center grid in parent view
            centerXConstraint,
            centerYConstraint,
            // Constrain rowClues to left of grid
            rowCluesStackView.topAnchor
                .constraint(equalTo: gridStackView.topAnchor),
            rowCluesStackView.bottomAnchor
                .constraint(equalTo: gridStackView.bottomAnchor),
            rowCluesStackView.trailingAnchor
                .constraint(equalTo: gridStackView.leadingAnchor,
                            constant: -cluesToGridPadding),
            // Constrain colClues to top of grid
            colCluesStackView.leadingAnchor
                .constraint(equalTo: gridStackView.leadingAnchor),
            colCluesStackView.trailingAnchor
                .constraint(equalTo: gridStackView.trailingAnchor),
            colCluesStackView.bottomAnchor
                .constraint(equalTo: gridStackView.topAnchor,
                            constant: -cluesToGridPadding),
        ])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Width of row clues and padding between clues and puzzle
        let rowCluesWidth = rowCluesStackView.frame.width +
            cluesToGridPadding
        /// Height of column clues and padding between clues and puzzle
        let colCluesHeight = colCluesStackView.frame.height +
            cluesToGridPadding
        updateConstraintConstants(rowCluesWidth, colCluesHeight)
        
        // Only one length constraint should be activated at a time
        // Stack view will determine size of the other length
        // Deactivate old constraints
        NSLayoutConstraint.deactivate([
            widthConstraint,
            heightConstraint
        ])
        // Activate ruling constraint so entire puzzle is visible within view
        NSLayoutConstraint.activate([
            getRulingConstraint(rowCluesWidth, colCluesHeight)
        ])
    }
    /// Determines which constraint needs to be activated in order for entire puzzle to be visible
    /// - Parameter rowCluesWidth: The width of the row clues stack view
    /// - Parameter colCluesHeight: The height of the column clues stack view
    private func getRulingConstraint(
        _ rowCluesWidth: CGFloat,
        _ colCluesHeight: CGFloat
    ) -> NSLayoutConstraint {
        /// Maximum width of a single square depending on what's left over after clues are rendered
        let maxSquareWidth = (frame.width - rowCluesWidth) /
            CGFloat(clues.colClues.count)
        /// Maximum height of a single square depending on what's left over after clues are rendered
        let maxSqaureHeight = (frame.height - colCluesHeight) /
            CGFloat(clues.rowClues.count)
        // Get smallest length
        let squareLength = min(maxSquareWidth, maxSqaureHeight)
        // Convert length to pixels
        let pixels = squareLength * UIScreen.main.scale
        // Check if squares will be less than 44 pixels and send to subscribers (too hard to tap if true)
        squaresTooSmall.send(pixels < 44)
        // The smallest maximum length determines which constraint to activate
        // so the entire puzzle fits within the parent view
        return maxSquareWidth < maxSqaureHeight ?
            widthConstraint : heightConstraint
        // If max lengths happen to be equal, either constraint will work
    }
    /// Updates width, height, and centering constraint constants based off of given width and height of clues
    /// - Parameter rowCluesWidth: The width of the row clues stack view
    /// - Parameter colCluesHeight: The height of the column clues stack view
    private func updateConstraintConstants(
        _ rowCluesWidth: CGFloat,
        _ colCluesHeight: CGFloat
    ) {
        // Leave room for clues to be displayed
        widthConstraint.constant = -rowCluesWidth
        heightConstraint.constant = -colCluesHeight
        // Center grid and clues horizontally and vertically
        centerXConstraint.constant = rowCluesWidth / 2
        centerYConstraint.constant = colCluesHeight / 2
    }
    
    // MARK: - Puzzle Setup
    /// Sets up puzzle. Removes old clues and grid before building and rendering them again.
    ///
    /// Should be called after `clues` changes
    private func setupPuzzle() {
        setupClues(rowCluesStackView)
        setupClues(colCluesStackView)
        setupGrid()
    }
    private func setupClues(_ cluesStackView: UIStackView) {
        // Delete old clues
        for subView in cluesStackView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        // Get desired array of clues
        let stackClues = cluesStackView == rowCluesStackView ?
            clues.rowClues : clues.colClues
        // For each array of clues in desired clues array
        for clues in stackClues {
            // Create stack view to hold every clue
            let innerStackView = UIStackView()
            // Axis should be horizontal for row clues and vertically for column clues
            innerStackView.axis = cluesStackView == rowCluesStackView ?
                .horizontal : .vertical
            innerStackView.spacing = innerCluesPadding
            cluesStackView.addArrangedSubview(innerStackView)
            /// Makes an returns a label with the `clue` as its text
            func clueLabel(_ clue: Int) -> AccessibleLabel {
                let label = AccessibleLabel()
                label.text = "\(clue)"
                // Text alignment should be right for row clues and center for column clues
                // so they line up nicely against the grid
                label.textAlignment = cluesStackView == rowCluesStackView ?
                    .right : .center
                return label
            }
            guard !clues.isEmpty else {
                innerStackView.addArrangedSubview(clueLabel(0))
                continue
            }
            for clue in clues {
                innerStackView.addArrangedSubview(clueLabel(clue))
            }
        }
    }
    /// Setsup stack view (vertical) that holds each horizontal stack view to make the grid.
    private func setupGrid() {
        // Delete old grid
        for subview in gridStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        // Loop through the number of vertical rows desired
        for col in 0..<clues.rowClues.count {
            // Create horizontal stack view for each desired row
            /// Stack view containing all squares in the row
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 0
            
            // Loop through number of horizontal rows desired
            // Starting at 1 so tags are 1 indexed (not 0 which is default for view tags)
            for row in 1...clues.colClues.count {
                /// Unique tag for each square (starting with 1)
                let number = row + (clues.colClues.count * col)
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
                if col == 0 && row == 1 { referenceSquare = square }
                // Add square to horizontal stack view
                stackView.addArrangedSubview(square)
            }
            // Add row view to grid stack view
            gridStackView.addArrangedSubview(stackView)
        }
    }
    
    func filledSquaresAsClues() -> PuzzleClues {
        return maker.getClues()
    }
    func clear() {
        setupGrid()
        validator = PuzzleValidator(from: clues)
    }
}
