//
//  TutorialViewController.swift
//  Paint a Pic
//
//  Created by Samantha Gatt on 8/3/20.
//  Copyright © 2020 Samantha Gatt. All rights reserved.
//

import UIKit
import Combine

final class TutorialViewController: UIViewController {
    
    var currentIndex = 0 {
        didSet {
            if currentIndex < 0 { currentIndex = 0 }
            if currentIndex >= tutorials.count {
                alertFinished()
                return
            }
            puzzleView.clues = tutorials[currentIndex].clues
            instructionsLabel.text = tutorials[currentIndex].instruction
            nextButton.isEnabled = false
        }
    }
    var subs: Set<AnyCancellable> = []
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var puzzleView: PuzzleView!
    @IBOutlet weak var instructionsLabel: UILabel!
    private lazy var pointingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pointing"))
        imageView.tintColor = .systemBackground
        imageView.alpha = 0
        return imageView
    }()
    private lazy var pointingFillImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pointing.fill"))
        imageView.tintColor = .label
        imageView.alpha = 0
        return imageView
    }()
    
    @IBAction func goToNextStep(_ sender: UIButton) { currentIndex += 1 }
    @IBAction func exitTutorial(_ sender: UIButton) { alertExit() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(pointingFillImageView, pointingImageView)
        puzzleView.clues = tutorials[0].clues
        instructionsLabel.text = tutorials[0].instruction
        puzzleView.puzzleValidity.sink { [weak self] isValid in
            if isValid {
                self?.nextButton.isEnabled = true
            }
        }.store(in: &subs)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var startFrame = puzzleView.getFirstFrameOfRow(0) ?? .zero
        startFrame = puzzleView.convert(startFrame, to: view.coordinateSpace)
        let startOrig = CGPoint(x: startFrame.origin.x,
                           y: startFrame.origin.y + startFrame.size.height / 3)
        let startSize = CGSize(width: 90, height: 90)
        startFrame = CGRect(origin: startOrig, size: startSize)
        
        let midSize = startSize - 20
        let midFrame = CGRect(origin: startOrig, size: midSize)
        
        var endFrame = puzzleView.getLastFrameOfRow(0) ?? .zero
        endFrame = puzzleView.convert(endFrame, to: view.coordinateSpace)
        let endOrig = CGPoint(x: endFrame.origin.x, y: startOrig.y)
        endFrame = CGRect(origin: endOrig, size: midSize)
        
        let endSize = midSize + 10
        
        pointingImageView.frame = startFrame
        pointingFillImageView.frame = startFrame
        let duration: TimeInterval = 3.25
        UIView.animateKeyframes(withDuration: duration, delay: 1.25, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0/duration,
                               relativeDuration: 0.75/duration,
                               animations: {
                                self.pointingImageView.frame = midFrame
                                self.pointingFillImageView.frame = midFrame
                                self.pointingImageView.alpha = 1
                                self.pointingFillImageView.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75/duration,
                               relativeDuration: 2/duration,
                               animations: {
                                self.pointingImageView.frame = endFrame
                                self.pointingFillImageView.frame = endFrame
            })
            UIView.addKeyframe(withRelativeStartTime: 2.75/duration,
                               relativeDuration: 0.5/duration,
                               animations: {
                                self.pointingImageView.frame.size = endSize
                                self.pointingFillImageView.frame.size = endSize
                                self.pointingImageView.alpha = 0
                                self.pointingFillImageView.alpha = 0
            })
        }) { _ in
            self.pointingImageView.isHidden = true
            self.pointingFillImageView.isHidden = true
        }
    }
    
    private func alertExit() {
        alert(title: "Are you sure you want to exit?",
              message: """
                You can come back to the tutorial at any time by going to the \
                game settings
                """,
              preferredStyle: .alert,
              actions: [
                UIAlertAction(title: "Exit",
                              style: .destructive) { [weak self] _ in
                                self?.dismiss(animated: true)
                }
        ])
    }
    private func alertFinished() {
        alert(title: "You've completed the tutorial",
              message: """
                You can redo the tutorial at any time by going to the game \
                settings
                """,
              preferredStyle: .alert,
              actions: [
                UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true)
                }
        ])
    }
}

func + (lhs: CGSize, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
}
func += (lhs: inout CGSize, rhs: CGFloat) {
    lhs = lhs + rhs
}

func - (lhs: CGSize, rhs: CGFloat) -> CGSize {
    CGSize(width: lhs.width - rhs, height: lhs.height - rhs)
}
func -= (lhs: inout CGSize, rhs: CGFloat) {
    lhs = lhs - rhs
}
