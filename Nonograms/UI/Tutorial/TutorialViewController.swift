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
    private lazy var circleLayer: CAShapeLayer = {
        let circle = UIBezierPath(arcCenter: .zero, radius: 40, startAngle: 0,
                                  endAngle: 2 * .pi, clockwise: true)
        let layer = CAShapeLayer()
        layer.path = circle.cgPath
        layer.lineWidth = 2
        layer.lineCap = .round
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.label.cgColor
        layer.transform = CATransform3DMakeScale(0, 0, 1);
        view.layer.addSublayer(layer)
        return layer
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
    
    private func panAnim(from fromSquare: CGRect,
                         to toSquare: CGRect,
                         delay: TimeInterval = 0.75,
                         speed: CGFloat = 108,
                         completion: @escaping () -> Void = {}) {
        let fadeInDur = 0.5
        let pulseDur = 0.75
        let pulseDelay = 0.25
        let opacityDelay = 0.25
        let panDelay = 0.5
        let fadeOutDur = 0.5
        
        // Tap anim
        let circleX = fromSquare.origin.x + fromSquare.size.width / 2
        let circleY = fromSquare.origin.y + fromSquare.size.height / 2
        circleLayer.position = CGPoint(x: circleX, y: circleY)
        
        let scaleAnim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        scaleAnim.beginTime = CACurrentMediaTime() + delay +
            fadeInDur + pulseDelay + opacityDelay
        scaleAnim.duration = pulseDur - opacityDelay
        scaleAnim.fromValue = 1
        scaleAnim.toValue = 0
        circleLayer.add(scaleAnim, forKey: "scale")
        
        let opacityAnim = CABasicAnimation(keyPath: "transform.scale")
        opacityAnim.beginTime = CACurrentMediaTime() + delay +
            fadeInDur + pulseDelay
        opacityAnim.duration = pulseDur
        opacityAnim.fromValue = 0
        opacityAnim.toValue = 1
        circleLayer.add(opacityAnim, forKey: "opacity")
        
        // Pointing anim
        let distance = abs(toSquare.origin.x - fromSquare.origin.x)
        let panDur = TimeInterval(distance / speed)
        let startOrig = CGPoint(x: fromSquare.origin.x,
                                y: fromSquare.origin.y +
                                    fromSquare.size.height / 3)
        let startSize = CGSize(width: 90, height: 90)
        let startFrame = CGRect(origin: startOrig, size: startSize)
        
        let midSize = startSize - 20
        let midFrame = CGRect(origin: startOrig, size: midSize)
        
        let endOrig = CGPoint(x: toSquare.origin.x,
                                y: toSquare.origin.y +
                                    toSquare.size.height / 3)
        let endFrame = CGRect(origin: endOrig, size: midSize)
        let endSize = midSize + 10
        
        pointingImageView.frame = startFrame
        pointingFillImageView.frame = startFrame
        pointingImageView.isHidden = false
        pointingFillImageView.isHidden = false
        
        let dur: TimeInterval = fadeInDur + panDelay + panDur + fadeOutDur
        UIView.animateKeyframes(withDuration: dur, delay: delay, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0 / dur,
                               relativeDuration: fadeInDur / dur,
                               animations: {
                                self.pointingImageView.frame = midFrame
                                self.pointingFillImageView.frame = midFrame
                                self.pointingImageView.alpha = 1
                                self.pointingFillImageView.alpha = 1
            })
            let panStartTime = (fadeInDur + panDelay)
            UIView.addKeyframe(withRelativeStartTime: panStartTime / dur,
                               relativeDuration: panDur / dur,
                               animations: {
                                self.pointingImageView.frame = endFrame
                                self.pointingFillImageView.frame = endFrame
            })
            let fadeOutStartTime = panStartTime + panDur
            UIView.addKeyframe(withRelativeStartTime: fadeOutStartTime / dur,
                               relativeDuration: fadeOutDur / dur,
                               animations: {
                                self.pointingImageView.frame.size = endSize
                                self.pointingFillImageView.frame.size = endSize
                                self.pointingImageView.alpha = 0
                                self.pointingFillImageView.alpha = 0
            })
        }) { _ in
            self.pointingImageView.isHidden = true
            self.pointingFillImageView.isHidden = true
            completion()
        }
    }
    private func tapAnim(at square: CGRect,
                         delay: TimeInterval = 0.75,
                         speed: CGFloat = 108,
                         completion: @escaping () -> Void = {}) {
        panAnim(from: square, to: square, delay: delay, speed: speed,
                completion: completion)
    }
    private func doFirstAnim() {
        let fromSquare = puzzleView.getFirstFrameOfRow(0, in: space) ?? .zero
        let toSquare = puzzleView.getLastFrameOfRow(0, in: space) ?? .zero
        panAnim(from: fromSquare, to: toSquare) { self.animDone = true }
    }
    private func doSecondAnim() {
        let square1 = puzzleView.getFirstFrameOfRow(0, in: space) ?? .zero
        let square2 = puzzleView.getFirstFrameOfCol(1, in: space) ?? .zero
        let square3 = puzzleView.getFirstFrameOfCol(3, in: space) ?? .zero
        let square4 = puzzleView.getLastFrameOfRow(0, in: space) ?? .zero
        let square5 = puzzleView.getFirstFrameOfRow(1, in: space) ?? .zero
        let square6 = puzzleView.getLastFrameOfCol(2, in: space) ?? .zero
        let square7 = puzzleView.getLastFrameOfRow(1, in: space) ?? .zero
        
        panAnim(from: square1, to: square2, speed: 65) {
            self.panAnim(from: square3, to: square4, delay: 0.5, speed: 65) {
                self.tapAnim(at: square5, delay: 0.5) {
                    self.tapAnim(at: square6, delay: 0.5) {
                        self.tapAnim(at: square7, delay: 0.5) {
                            self.animDone = true
                        }
                    }
                }
            }
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
