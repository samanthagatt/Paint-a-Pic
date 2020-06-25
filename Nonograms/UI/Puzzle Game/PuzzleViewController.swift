//
//  PuzzleViewController.swift
//  Nonograms
//
//  Created by Samantha Gatt on 6/10/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit
import Combine

extension Notification.Name {
    static let puzzleSolved = Notification.Name(rawValue: "puzzleSolved")
}

final class PuzzleViewController: UIViewController {
    /// Set of all subscriptions. Each will be canceled on deallocation.
    private var subscriptions = Set<AnyCancellable>()
    private var hasBeenEdited = false
    var puzzleIndex: Int?
    var puzzleRules: PuzzleRules? {
        didSet {
            if let rules = puzzleRules {
                loadViewIfNeeded()
                puzzleView.rules = rules
            }
            title = puzzleRules?.name
        }
    }

    @IBOutlet private weak var puzzleView: PuzzleView!
    @IBOutlet private weak var exButton: UIButton!
    @IBOutlet private weak var fillButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exButton.layer.borderColor = UIColor.label.cgColor
        exButton.layer.cornerRadius = 5
        fillButton.layer.borderColor = UIColor.label.cgColor
        fillButton.layer.borderWidth = 2
        fillButton.layer.cornerRadius = 5
        
        let backImage = UIImage(systemName: "chevron.left")
        let buttonImageView = UIImageView(image: backImage)
        buttonImageView.contentMode = .scaleAspectFit
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        let buttonLabel = UILabel()
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLabel.text = "Back"
        let backButton = UIButton(type: .custom)
        buttonLabel.textColor = backButton.tintColor
        backButton.addSubview(buttonImageView)
        backButton.addSubview(buttonLabel)
        
        NSLayoutConstraint.activate([
            buttonImageView.centerYAnchor
                .constraint(equalTo: backButton.centerYAnchor),
            buttonLabel.centerYAnchor
                .constraint(equalTo: backButton.centerYAnchor),
            buttonImageView.heightAnchor
                .constraint(equalTo: buttonLabel.heightAnchor),
            buttonLabel.leadingAnchor
                .constraint(equalTo: buttonImageView.trailingAnchor,
                            constant: 6),
            buttonImageView.leadingAnchor
                .constraint(equalTo: backButton.leadingAnchor),
            buttonImageView.topAnchor
                .constraint(equalTo: backButton.topAnchor),
            buttonImageView.bottomAnchor
                .constraint(equalTo: backButton.bottomAnchor),
            buttonLabel.trailingAnchor
                .constraint(equalTo: backButton.trailingAnchor)
        ])
        
        backButton.addTarget(self,
                             action: #selector(back),
                             for: .touchUpInside)
        let backBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
        
        // Subscribe to updates to see if puzzle has been solved
        puzzleView.puzzleValidity.sink { [weak self] isValid in
            guard let self = self else { return }
            if !self.hasBeenEdited { self.hasBeenEdited = true }
            if isValid {
                NotificationCenter.default.post(name: .puzzleSolved,
                                                object: self.puzzleIndex)
                let alert = UIAlertController(title: "Yay!", message: "You solved the puzzle :)", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default)
                alert.addAction(okayAction)
                self.present(alert, animated: true)
                self.hasBeenEdited = false
            }
        }.store(in: &subscriptions)
    }
    
    @objc func back() {
        if hasBeenEdited {
            let alert = UIAlertController(
                title: "Go back?",
                message: """
                You've already started this puzzle. \
                Are you sure you want to go back? \
                All your progress will be lost.
                """,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Go Back",
                                          style: .destructive) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func setExMode(_ sender: Any) {
        exButton.layer.borderWidth = 2
        fillButton.layer.borderWidth = 0
        puzzleView.fillMode = .ex
    }
    @IBAction func setFillMode(_ sender: Any) {
        fillButton.layer.borderWidth = 2
        exButton.layer.borderWidth = 0
        puzzleView.fillMode = .fill
    }
}
