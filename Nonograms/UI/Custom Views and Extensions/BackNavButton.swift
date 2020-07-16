//
//  BackNavButton.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 7/15/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit

final class BackNavButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    private func setupView() {
        let backImage = UIImage(systemName: "chevron.left")
        let buttonImageView = UIImageView(image: backImage)
        buttonImageView.contentMode = .scaleAspectFit
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        let buttonLabel = UILabel()
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLabel.text = "Back"
        buttonLabel.textColor = tintColor
        addSubviews(buttonImageView, buttonLabel)
        
        NSLayoutConstraint.activate([
            buttonImageView.centerYAnchor
                .constraint(equalTo: centerYAnchor),
            buttonLabel.centerYAnchor
                .constraint(equalTo: centerYAnchor),
            buttonImageView.heightAnchor
                .constraint(equalTo: buttonLabel.heightAnchor),
            buttonLabel.leadingAnchor
                .constraint(equalTo: buttonImageView.trailingAnchor,
                            constant: 6),
            buttonImageView.leadingAnchor
                .constraint(equalTo: leadingAnchor),
            buttonImageView.topAnchor
                .constraint(equalTo: topAnchor),
            buttonImageView.bottomAnchor
                .constraint(equalTo: bottomAnchor),
            buttonLabel.trailingAnchor
                .constraint(equalTo: trailingAnchor)
        ])
    }
}
