//
//  FocusView.swift
//  BioScope
//
//  Created by Timothy DenOuden on 4/24/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

protocol OnFocusChangeDelegate {
    func didReachTop()
    func didSliderValueChange(value: Float)
    func didReachBottom()
    func didTap()
    func didShowAnimationBegin()
    func didHideAnimationEnd()
}

class FocusView: UIView, UIGestureRecognizerDelegate, CAAnimationDelegate {
    
    let dotSize = CGFloat(8)
    let iconSize = CGFloat(24)
    let boundsSize = CGFloat(64)
    let maxSize = CGFloat(128)
    var startPath: UIBezierPath!
    var endPath: UIBezierPath!
    var circleLayer: CAShapeLayer!
    var dotLayer: CAShapeLayer!
    var delegate: OnFocusChangeDelegate?
    var isFocusShown = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        startPath = UIBezierPath(ovalIn: CGRect(x: boundsSize / 2, y: boundsSize / 2, width: 0, height: 0))
        endPath = UIBezierPath(ovalIn: CGRect(x: -(boundsSize / 2), y: -(boundsSize / 2), width: maxSize, height: maxSize))
        
        circleLayer = CAShapeLayer()
        circleLayer.path = startPath!.cgPath
        circleLayer.fillColor = UIColor.black.cgColor
        circleLayer.strokeColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 0.0
        self.layer.addSublayer(circleLayer)
        
        let dotPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        dotLayer = CAShapeLayer()
        dotLayer.path = dotPath.cgPath
        dotLayer.fillColor = UIColor.white.cgColor
        dotLayer.strokeColor = UIColor.clear.cgColor
        dotLayer.lineWidth = 0.0
        dotLayer.isHidden = true
        circleLayer.addSublayer(dotLayer)
        moveDot(toAngleRad: 0)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(FocusView.onPan(sender:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FocusView.onTap(sender:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        
        let icon = UIImageView(frame: CGRect(x: (self.bounds.width - iconSize) / 2, y: (self.bounds.height - iconSize) / 2, width: iconSize, height: iconSize))
        icon.image = #imageLiteral(resourceName: "ic_camera_white")
        addSubview(icon)
    }
    
    private func showFocus() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.delegate = self
        animation.setValue("show", forKey: "displayChange")
        circleLayer.path = endPath.cgPath
        circleLayer.add(animation, forKey: "showAnimation")
        isFocusShown = true
    }
    
    private func hideFocus() {
        dotLayer.isHidden = true
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = endPath
        animation.toValue = startPath
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.delegate = self
        animation.setValue("hide", forKey: "displayChange")
        circleLayer.path = startPath.cgPath
        circleLayer.add(animation, forKey: "hideAnimation")
        isFocusShown = false
    }
    
    private func moveDot(toAngleRad angle: CGFloat) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        let correctedAngle = angle + .pi / 2
        dotLayer.position.x = ((self.bounds.width - dotSize) / 2) + ((maxSize / 2 - dotSize) * sin(correctedAngle))
        dotLayer.position.y = ((self.bounds.height - dotSize) / 2) + ((maxSize / 2 - dotSize) * cos(correctedAngle))
        CATransaction.commit()
    }
    
    private func updateValue(fromAngle angle: CGFloat) {
        let value = (angle / (.pi / 2)) - 1
        if(value == 1.0) {
            self.delegate?.didReachTop()
        }
        else if(value == 0.0) {
            self.delegate?.didReachBottom()
        }
        else {
            self.delegate?.didSliderValueChange(value: Float(value))
        }
    }
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        if(isFocusShown) {
            hideFocus()
        }
        else {
            showFocus()
        }
        self.delegate?.didTap()
    }
    
    @objc func onPan(sender: UIPanGestureRecognizer) {
        if(sender.state == .began) {
            showFocus()
        }
        else if(sender.state == .changed) {
            let touchPoint = sender.location(in: self.window)
            let deltaX = touchPoint.x - self.center.x
            let deltaY = self.window!.bounds.height - touchPoint.y - (self.window!.bounds.height - self.center.y)
            var angle = atan2(deltaY, deltaX)
            if(angle <= 0) {
                angle = .pi
            }
            else if (angle <= .pi / 2 && angle >= 0) {
                angle = .pi / 2
            }
            updateValue(fromAngle: angle)
            moveDot(toAngleRad: angle)
        }
        else {
            hideFocus()
        }
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        let key = anim.value(forKey: "displayChange") as! String
        if(key == "hide") {
            dotLayer.isHidden = true
        }
        else if(key == "show") {
            self.delegate?.didShowAnimationBegin()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let key = anim.value(forKey: "displayChange") as! String
        if(key == "show") {
            dotLayer.isHidden = false
        }
        else if(key == "hide") {
            self.delegate?.didHideAnimationEnd()
            dotLayer.isHidden = true
        }
    }
    
    private func viewFromNibForClass() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
