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
    private var filledColor: UIColor = .label
    /// Enum representing if the square is filled in, empty, or marked with an `x`
    private(set) var fillState: PuzzleSquareFillState = .empty {
        didSet { updateFill() }
    }
    private var beforeTempFillState: PuzzleSquareFillState?
    
    private let exImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "xmark")
        imageView.tintColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
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
        filledColor: UIColor = .label
    ) {
        self.init()
        self.tag = tag
        self.emptyColor = emptyColor
        self.filledColor = filledColor
    }
    /// Handles setting up view when initialized
    private func sharedInit() {
        addSubview(exImageView)
        exImageView.isHidden = true
        
        backgroundColor = emptyColor
        layer.borderColor = UIColor.label.cgColor
        layer.borderWidth = 1
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Make square view a square
            widthAnchor.constraint(equalTo: heightAnchor),
            // Constrain ex to view
            exImageView.topAnchor.constraint(equalTo: topAnchor),
            exImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            exImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            exImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateFill() {
        switch fillState {
        case .empty:
            backgroundColor = emptyColor
            exImageView.isHidden = true
        case .filled:
            backgroundColor = filledColor
            exImageView.isHidden = true
        case .exed:
            backgroundColor = emptyColor
            exImageView.isHidden = false
        }
    }
    
    func setState(for mode: PuzzleFillMode) {
        fillState.setNewState(for: mode)
    }
    func tempFill(for mode: PuzzleTempFillMode) -> Bool {
        guard let temp = fillState.getNewState(for: mode) else { return false }
        beforeTempFillState = fillState
        fillState = temp
        return true
    }
    func cancelTempFill() {
        guard let beforeTemp = beforeTempFillState else { return }
        fillState = beforeTemp
        beforeTempFillState = nil
    }
    func confirmTempFill() {
        beforeTempFillState = nil
    }
}
