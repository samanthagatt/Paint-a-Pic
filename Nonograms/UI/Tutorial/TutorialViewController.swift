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
    
    var space: UICoordinateSpace { view.coordinateSpace }
    var isValid = false {
        didSet { enableNextButton() }
    }
    private func enableNextButton() {
        if isValid, animDone {
            isValid = false
            animDone = false
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    var animDone = false { didSet { enableNextButton() } }
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
            puzzleView.layoutIfNeeded()
            if currentIndex == 1 { doSecondAnim() }
            if currentIndex == 2 { puzzleView.hideColClues() }
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
        imageView.isHidden = true
        return imageView
    }()
    private lazy var pointingFillImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pointing.fill"))
        imageView.tintColor = .label
        imageView.alpha = 0
        imageView.isHidden = true
        return imageView
    }()
    private lazy var circle: UIView = {
        let circle = UIView()
        circle.frame = CGRect(origin: .zero,
                              size: CGSize(width: 80, height: 80))
        circle.layer.cornerRadius = 40
        circle.backgroundColor = .clear
        circle.layer.borderColor = UIColor.label.cgColor
        circle.layer.borderWidth = 2
        circle.layer.opacity = 0
        view.addSubview(circle)
        return circle
    }()
    
    @IBAction func goToNextStep(_ sender: UIButton) { currentIndex += 1 }
    @IBAction func exitTutorial(_ sender: UIButton) { alertExit() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(pointingFillImageView, pointingImageView)
        puzzleView.clues = tutorials[0].clues
        instructionsLabel.text = tutorials[0].instruction
        puzzleView.puzzleValidity.sink { [weak self] isValid in
            if isValid { self?.isValid = true }
        }.store(in: &subs)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doFirstAnim()
    }
    
    private func scaleAndFadeCircle(atSquare square: CGRect,
                                    delay: TimeInterval = 0,
                                    start: TimeInterval,
                                    dur: TimeInterval,
                                    totalDur: TimeInterval) {
        let opacityDelay = 0.25
        let opacityDur = dur - opacityDelay <= 0 ? dur : dur - opacityDelay
        let opacityStart = delay + start + opacityDelay
        
        let circleX = square.origin.x + square.size.width / 2
        let circleY = square.origin.y + square.size.height / 2

        // Make sure circle's configured right to start
        UIView.addKeyframe(withRelativeStartTime: (delay + start) / totalDur,
                           relativeDuration: 0) {
                            let transform = CGAffineTransform(scaleX: 0.01,
                                                              y: 0.01)
                            self.circle.transform = transform
                            self.circle.layer.opacity = 1
                            self.circle.frame.origin = CGPoint(x: circleX,
                                                               y: circleY)
        }
        UIView.addKeyframe(withRelativeStartTime: (delay + start) / totalDur,
                           relativeDuration: dur / totalDur) {
                            let transform = CGAffineTransform(scaleX: 1, y: 1)
                            self.circle.transform = transform
        }
        UIView.addKeyframe(withRelativeStartTime: opacityStart / totalDur,
                           relativeDuration: opacityDur / totalDur) {
                            self.circle.layer.opacity = 0
        }
    }
    /// Pointer images get smaller and fade in
    private func fadeInPointers(atSquare square: CGRect,
                                delay: TimeInterval = 0,
                                start: TimeInterval,
                                dur: TimeInterval,
                                totalDur: TimeInterval) {
        // Get pointer images in position to start animating
        let startOrig = CGPoint(x: square.origin.x,
                                y: square.origin.y +
                                    square.size.height / 3)
        let startSize = CGSize(width: 90, height: 90)
        let startFrame = CGRect(origin: startOrig, size: startSize)
        
        UIView.addKeyframe(withRelativeStartTime: (delay + start) / totalDur,
                           relativeDuration: 0) {
                            self.pointingImageView.frame = startFrame
                            self.pointingFillImageView.frame = startFrame
                            self.pointingImageView.isHidden = false
                            self.pointingFillImageView.isHidden = false
        }
        
        UIView.addKeyframe(withRelativeStartTime: (delay + start) / totalDur,
                           relativeDuration: dur / totalDur) {
                            self.pointingImageView.frame.size -= 20
                            self.pointingFillImageView.frame.size -= 20
                            self.pointingImageView.alpha = 1
                            self.pointingFillImageView.alpha = 1
        }
    }
    private func panPointers(toSquare square: CGRect, delay: TimeInterval = 0,
                             start: TimeInterval, dur: TimeInterval,
                             totalDur: TimeInterval) {
        // Pointer images drag to end point
        let endOrig = CGPoint(x: square.origin.x,
                                y: square.origin.y +
                                    square.size.height / 3)
        UIView.addKeyframe(withRelativeStartTime: (delay + start) / totalDur,
                           relativeDuration: dur / totalDur) {
                            self.pointingImageView.frame.origin = endOrig
                            self.pointingFillImageView.frame.origin = endOrig
        }
    }
    private func fadeOutPointers(delay: TimeInterval = 0,
                                 start: TimeInterval,
                                 dur: TimeInterval,
                                 totalDur: TimeInterval) {
        // Pointer images get larger and fade out
        UIView.addKeyframe(withRelativeStartTime: (delay + start) / totalDur,
                           relativeDuration: dur / totalDur) {
                            self.pointingImageView.frame.size += 10
                            self.pointingFillImageView.frame.size += 10
                            self.pointingImageView.alpha = 0
                            self.pointingFillImageView.alpha = 0
        }
    }
    private func getDurForTap(fadeDur: Double = 0.5,
                              circleDur: Double = 0.75,
                              fadeOutDelay: Double) -> Double {
        fadeDur + max(circleDur, fadeOutDelay + fadeDur)
    }
    private func tapPointers(atSquare square: CGRect,
                             start: Double, fadeDur: Double = 0.5,
                             circleDur: Double = 0.75, fadeOutDelay: Double,
                             totalDur: Double) {
        let circleStart = start + fadeDur
        let fadeOutStart = circleStart + max(circleDur, fadeOutDelay)
        fadeInPointers(atSquare: square, start: start, dur: fadeDur,
                       totalDur: totalDur)
        scaleAndFadeCircle(atSquare: square, start: circleStart,
                           dur: circleDur, totalDur: totalDur)
        fadeOutPointers(start: fadeOutStart, dur: fadeDur, totalDur: totalDur)
    }
    private func getDurForTapAndPan(fadeDur: Double = 0.5,
                                    circleDur: Double = 0.75,
                                    panDelay: Double = 0.5,
                                    panDur: Double) -> Double {
        fadeDur + panDelay + panDur + fadeDur
    }
    private func tapAndPanPointers(fromSquare: CGRect, toSquare: CGRect,
                                   start: Double, fadeDur: Double = 0.5,
                                   circleDur: Double = 0.75,
                                   panDelay: Double = 0.5,
                                   panDur: Double, totalDur: Double) {
        let circleStart = start + fadeDur
        let panStart = circleStart + panDelay
        let fadeOutStart = panStart + panDur
        fadeInPointers(atSquare: fromSquare, start: start, dur: fadeDur,
                       totalDur: totalDur)
        scaleAndFadeCircle(atSquare: fromSquare, start: circleStart,
                           dur: circleDur, totalDur: totalDur)
        panPointers(toSquare: toSquare, start: panStart, dur: panDur,
                    totalDur: totalDur)
        fadeOutPointers(start: fadeOutStart, dur: fadeDur, totalDur: totalDur)
    }
    private func doFirstAnim() {
        let beginDelay = 0.5
        let panDur = 2.0
        let dur = getDurForTapAndPan(panDur: panDur)
        
        let fromSquare = self.puzzleView
            .getFirstFrameOfRow(0, in: self.space) ?? .zero
        let toSquare = self.puzzleView
            .getLastFrameOfRow(0, in: self.space) ?? .zero
        
        UIView.animateKeyframes(
            withDuration: dur,
            delay: beginDelay,
            animations: {
                self.tapAndPanPointers(fromSquare: fromSquare,
                                       toSquare: toSquare,
                                       start: 0, panDur: panDur,
                                       totalDur: dur)
                
        }) { _ in
            self.pointingImageView.isHidden = true
            self.pointingFillImageView.isHidden = true
            self.animDone = true
        }
    }
    private func doSecondAnim() {
        let beginDelay = 0.5
        let panDur = 1.0
        let rest = 0.5
        let fadeOutDelay = 0.25
        
        let panStart2 = getDurForTapAndPan(panDur: panDur) + rest
        let tapStart1 = panStart2 + getDurForTapAndPan(panDur: panDur) + rest
        let tapStart2 = tapStart1 + getDurForTap(fadeOutDelay: fadeOutDelay) + rest
        let tapStart3 = tapStart2 + getDurForTap(fadeOutDelay: fadeOutDelay) + rest
        let dur = tapStart3 + getDurForTap(fadeOutDelay: fadeOutDelay)
        
        let square1 = puzzleView.getFirstFrameOfRow(0, in: space) ?? .zero
        let square2 = puzzleView.getFirstFrameOfCol(1, in: space) ?? .zero
        let square3 = puzzleView.getFirstFrameOfCol(3, in: space) ?? .zero
        let square4 = puzzleView.getLastFrameOfRow(0, in: space) ?? .zero
        let square5 = puzzleView.getFirstFrameOfRow(1, in: space) ?? .zero
        let square6 = puzzleView.getLastFrameOfCol(2, in: space) ?? .zero
        let square7 = puzzleView.getLastFrameOfRow(1, in: space) ?? .zero
        
        UIView.animateKeyframes(
            withDuration: dur,
            delay: beginDelay,
            animations: {
                self.tapAndPanPointers(fromSquare: square1,
                                       toSquare: square2, start: 0,
                                       panDur: panDur, totalDur: dur)
                self.tapAndPanPointers(fromSquare: square3,
                                       toSquare: square4, start: panStart2,
                                       panDur: panDur, totalDur: dur)
                self.tapPointers(atSquare: square5, start: tapStart1,
                                 fadeOutDelay: fadeOutDelay, totalDur: dur)
                self.tapPointers(atSquare: square6, start: tapStart2,
                                 fadeOutDelay: fadeOutDelay, totalDur: dur)
                self.tapPointers(atSquare: square7, start: tapStart3,
                                 fadeOutDelay: fadeOutDelay, totalDur: dur)
        }) { _ in
            self.pointingImageView.isHidden = true
            self.pointingFillImageView.isHidden = true
            self.animDone = true
        }
    }
    private func alertExit() {
        alert(title: "Are you sure you want to exit?",
              message: """
                You can come back to the tutorial at any time by going to \
                the game settings
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
