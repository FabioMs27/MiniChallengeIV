//
//  AnimatedRingView.swift
//  MiniChallengeIV
//
//  Created by Fábio Maciel de Sousa on 11/05/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import UIKit

///Class that handles timer's progression bar
class AnimatedRingView: UIView {
    //MARK: - Atributes
    private static let animationDuration = CFTimeInterval(60)
    private let π = CGFloat.pi
    let startAngle = 1.5 * CGFloat.pi
    let circleStrokeWidth = CGFloat(2)
    let ringStrokeWidth = CGFloat(5)
    var proportion = CGFloat(0) {
        didSet {
            setNeedsLayout()
        }
    }
    var isRunning = false
    var totalTime: CGFloat = 0.0
    ///Circle path layer
    lazy var circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.init(89, 126, 124, 1).cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = self.circleStrokeWidth
        self.layer.addSublayer(circleLayer)
        return circleLayer
    }()
    ///Ring layer that goes through the circle path
    lazy var ringlayer: CAShapeLayer = {
        let ringlayer = CAShapeLayer()
        ringlayer.fillColor = UIColor.clear.cgColor
        ringlayer.strokeColor = UIColor.init(89, 126, 124, 1).cgColor
        ringlayer.lineCap = CAShapeLayerLineCap.round
        ringlayer.lineWidth = self.ringStrokeWidth
        self.layer.addSublayer(ringlayer)
        return ringlayer
    }()
    ///Pin layer that follows ring
    lazy var pinlayer: CAShapeLayer = {
        let pinlayer = CAShapeLayer()
        pinlayer.fillColor = UIColor.init(89, 126, 124, 1).cgColor
        self.layer.addSublayer(pinlayer)
        return pinlayer
    }()
    ///Circle background
    lazy var circleBackgroundLayer: CAShapeLayer = {
        let circleBackground = CAShapeLayer()
        circleBackground.fillColor = UIColor.init(229, 230, 220, 1).cgColor
        self.layer.addSublayer(circleBackground)
        circleBackground.zPosition =  -100
        return circleBackground
    }()
    //MARK: - Methods
    /**
     Method called when view is loaded. It draws the layers.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.backgroundColor = UIColor.init(244, 244, 240, 1)
        let radius = (min(frame.size.width, frame.size.height) - ringStrokeWidth - 2)/2
        let pinRadius = 7
        let circlebackgroundRadius = (80.55*radius)/90
        let size = self.frame.size
        let pos = CGPoint(x: size.width/2, y: size.height/2)
        let circlePath = UIBezierPath(arcCenter: pos, radius: radius, startAngle: startAngle, endAngle: startAngle + 2 * π, clockwise: true)
        let pinPath = CGPath(ellipseIn: CGRect(x: -pinRadius, y: Int(-radius) - pinRadius, width: 2 * pinRadius, height: 2 * pinRadius), transform: nil)
        let circleBackgroundPath = CGPath(ellipseIn: CGRect(x: -CGFloat(circlebackgroundRadius), y: -CGFloat(circlebackgroundRadius), width: CGFloat(2 * circlebackgroundRadius), height: CGFloat(2 * circlebackgroundRadius)), transform: nil)
        circleLayer.path = circlePath.cgPath
        ringlayer.path = circlePath.cgPath
        ringlayer.strokeEnd = proportion
        pinlayer.position = pos
        pinlayer.path = pinPath
        circleBackgroundLayer.position = pos
        circleBackgroundLayer.path = circleBackgroundPath
    }
    /**
     Method that starts the progress animation
     - Parameter startProportion: point in percentage of where the animation will start in the circle.(0 to 1)
     - Parameter startPinPos: angle in which the pin will start in the circle. It ranges from 0 to 360 (pi * 2)
     - Parameter endProportion: point in percentage of where the animation will end in the circle.(0 to 1)
     - Parameter duratino: The duration in seconds for the animations. It comes with a default value.
     */
    func animateRing(From startProportion: CGFloat,FromAngle startPinPos: CGFloat, To endProportion: CGFloat, Duration duration: CFTimeInterval = animationDuration, timing: CAMediaTimingFunctionName? = .linear) {
        self.isRunning = true
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = startProportion
        animation.toValue = endProportion
        animation.timingFunction = CAMediaTimingFunction(name: timing!)
        ringlayer.strokeEnd = 1
        ringlayer.strokeStart = 0
        ringlayer.add(animation, forKey: "animateRing")
        
        let pinAnimation = CABasicAnimation(keyPath: "transform.rotation")
        pinAnimation.fromValue = startPinPos
        pinAnimation.toValue = 2 * CGFloat.pi
        pinAnimation.timingFunction = CAMediaTimingFunction(name: timing!)
        pinAnimation.duration = duration
        pinAnimation.isAdditive = true
        pinlayer.add(pinAnimation, forKey: "animatePin")
    }
    /**
     Method for removing animation when finished or reseted
     */
    func removeAnimation(){
        pinlayer.removeAllAnimations()
        ringlayer.removeAllAnimations()
        proportion = 0
        isRunning = false
    }
    /**
     Method that calculates the starting point for when app went to background.
     - Parameter currTime: current time after coming from background.
     - Parameter toValue: Value when circle is filled. It can be endStroke or an angle.
     - returns: The new position that the circle should be according to new updated time value coming from background.
     */
    func calculateStartingPoint(With currTime: CGFloat, And toValue: CGFloat) -> CGFloat{
        if currTime <= 0 {return toValue}
        let newPos = toValue - ((currTime * toValue) / totalTime)
        return newPos
    }
}
