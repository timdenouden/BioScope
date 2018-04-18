//
//  ModeToggleView.swift
//  BioScope
//
//  Created by Timothy DenOuden on 4/25/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

protocol OnCaptureDelegate {
    func onCapture(mode: ModeToggleView.CaptureMode)
    func onModeChange(newMode: ModeToggleView.CaptureMode)
}

class ModeToggleView: UIView, UIGestureRecognizerDelegate {
    enum CaptureMode {
        case photo
        case video
        case layers
    }
    
    let topButtonSize = CGFloat(64)
    let leftRightButtonSize = CGFloat(16)
    let backgroundHeight = CGFloat(64)
    let leftRightOffset = CGFloat(32)
    let iconSize = CGFloat(24)
    
    var buttonLocations: [CGPoint]!
    var buttonColors: [UIColor]!
    var buttonLayers: [CALayer] = []
    var selectedButtonIndex = 0
    
    var topButton: UIButton!
    var rightButton: UIButton!
    var leftButton: UIButton!
    var delegate: OnCaptureDelegate?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
        buttonLocations = [
            CGPoint(x: (self.bounds.width - topButtonSize) / 2, y: 0),
            CGPoint(x: (self.bounds.width - topButtonSize) / 2 + leftRightOffset, y: self.bounds.height - topButtonSize + leftRightButtonSize),
            CGPoint(x: (self.bounds.width - topButtonSize) / 2 - leftRightOffset, y: self.bounds.height - topButtonSize + leftRightButtonSize)
        ]
        
        buttonColors = [
            UIColor.green,
            UIColor.red,
            UIColor.blue
        ]
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(ModeToggleView.onSwipeLeft(sender:)))
        swipeLeftGesture.delegate = self
        swipeLeftGesture.direction = .left
        self.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(ModeToggleView.onSwipeRight(sender:)))
        swipeRightGesture.delegate = self
        swipeRightGesture.direction = .right
        self.addGestureRecognizer(swipeRightGesture)
        
        self.backgroundColor = .clear
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.frame = CGRect(x: 0, y: topButtonSize / 2, width: self.bounds.width, height: backgroundHeight)
        backgroundLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        self.layer.addSublayer(backgroundLayer)
        
        // MARK: - Button setup
        
        let buttonFrame = CGRect(x: buttonLocations[0].x, y: buttonLocations[0].y, width: topButtonSize, height: topButtonSize)
        
        // MARK: - Top button setup
        
        let topButtonLayer = CALayer()
        topButtonLayer.anchorPoint = CGPoint.zero
        topButtonLayer.frame = buttonFrame
        topButtonLayer.cornerRadius = topButtonSize / 2
        topButtonLayer.backgroundColor = buttonColors[0].cgColor
        let innerTopIconLayer = CALayer()
        innerTopIconLayer.frame = CGRect(x: (buttonFrame.width - iconSize) / 2, y: (buttonFrame.height - iconSize) / 2, width: iconSize, height: iconSize)
        innerTopIconLayer.contents = UIImage(named: "ic_photo_camera_white")?.cgImage
        topButtonLayer.addSublayer(innerTopIconLayer)
        buttonLayers.append(topButtonLayer)
        self.layer.addSublayer(topButtonLayer)
        topButton = UIButton(frame: buttonFrame.insetBy(dx: 4, dy: 4))
        topButton.backgroundColor = .clear
        topButton.addTarget(self, action: #selector(ModeToggleView.onCaptureClick), for: .touchUpInside)
        self.addSubview(topButton)
        
        //  MARK: - Right button setup
        
        let rightButtonLayer = CAShapeLayer()
        rightButtonLayer.anchorPoint = CGPoint.zero
        rightButtonLayer.frame = buttonFrame
        rightButtonLayer.cornerRadius = topButtonSize / 2
        rightButtonLayer.backgroundColor = buttonColors[1].cgColor
        let innerRightIconLayer = CALayer()
        innerRightIconLayer.frame = CGRect(x: (buttonFrame.width - iconSize) / 2, y: (buttonFrame.height - iconSize) / 2, width: iconSize, height: iconSize)
        innerRightIconLayer.contents = UIImage(named: "ic_videocam_white")?.cgImage
        rightButtonLayer.addSublayer(innerRightIconLayer)
        buttonLayers.append(rightButtonLayer)
        self.layer.addSublayer(rightButtonLayer)
        rightButton = UIButton(frame: CGRect(x: buttonLocations[1].x + (topButtonSize - iconSize) / 2, y: buttonLocations[1].y + (topButtonSize - iconSize) / 2, width: iconSize, height: iconSize))
        rightButton.backgroundColor = .clear
        rightButton.addTarget(self, action: #selector(ModeToggleView.onRightClick), for: .touchUpInside)
        self.addSubview(rightButton)
        
        // MARK: - Left button setup

        let leftButtonLayer = CAShapeLayer()
        leftButtonLayer.anchorPoint = CGPoint.zero
        leftButtonLayer.frame = buttonFrame
        leftButtonLayer.cornerRadius = topButtonSize / 2
        leftButtonLayer.backgroundColor = buttonColors[2].cgColor
        let innerLeftIconLayer = CALayer()
        innerLeftIconLayer.frame = CGRect(x: (buttonFrame.width - iconSize) / 2, y: (buttonFrame.height - iconSize) / 2, width: iconSize, height: iconSize)
        innerLeftIconLayer.contents = UIImage(named: "ic_layers_white")?.cgImage
        leftButtonLayer.addSublayer(innerLeftIconLayer)
        buttonLayers.append(leftButtonLayer)
        self.layer.addSublayer(leftButtonLayer)
        leftButton = UIButton(frame: CGRect(x: buttonLocations[2].x + (topButtonSize - iconSize) / 2, y: buttonLocations[2].y + (topButtonSize - iconSize) / 2, width: iconSize, height: iconSize))
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(ModeToggleView.onLeftClick), for: .touchUpInside)
        self.addSubview(leftButton)
        
        for index in 0...2 {
            buttonLayers[index].position = buttonLocations[index]
            buttonLayers[index].backgroundColor = UIColor.clear.cgColor
        }
        let selectedLayer = buttonLayers[selectedButtonIndex]
        self.layer.sublayers!.append(self.layer.sublayers!.remove(at: self.layer.sublayers!.index(of: selectedLayer)!))
        selectedLayer.backgroundColor = buttonColors[selectedButtonIndex].cgColor
    }
    
    @objc func onCaptureClick() {
        if(selectedButtonIndex == 0) {
            self.delegate?.onCapture(mode: .photo)
        }
        else if(selectedButtonIndex == 1) {
            self.delegate?.onCapture(mode: .video)
        }
        else if(selectedButtonIndex == 2) {
            self.delegate?.onCapture(mode: .layers)
        }
    }
    
    @objc func onRightClick() {
        onSwipeLeft(sender: nil)
    }
    
    @objc func onLeftClick() {
        onSwipeRight(sender: nil)
    }
    
    @objc func onSwipeLeft(sender: UISwipeGestureRecognizer?) {
        selectedButtonIndex = wrapAroundOverBoundIndex(index: selectedButtonIndex + 1, maxSize: 2)
        print(selectedButtonIndex)
        buttonLocations.insert(buttonLocations.remove(at: 2), at: 0)
        for index in 0...2 {
            buttonLayers[index].position = buttonLocations[index]
            buttonLayers[index].backgroundColor = UIColor.clear.cgColor
        }
        let selectedLayer = buttonLayers[selectedButtonIndex]
        self.layer.sublayers!.append(self.layer.sublayers!.remove(at: self.layer.sublayers!.index(of: selectedLayer)!))
        selectedLayer.backgroundColor = buttonColors[selectedButtonIndex].cgColor
        if(selectedButtonIndex == 0) {
            self.delegate?.onModeChange(newMode: .photo)
        }
        else if(selectedButtonIndex == 1) {
            self.delegate?.onModeChange(newMode: .video)
        }
        else if(selectedButtonIndex == 2) {
            self.delegate?.onModeChange(newMode: .layers)
        }
    }
    
    @objc func onSwipeRight(sender: UISwipeGestureRecognizer?) {
        selectedButtonIndex = wrapAroundOverBoundIndex(index: selectedButtonIndex - 1, maxSize: 2)
        print(selectedButtonIndex)
        buttonLocations.insert(buttonLocations.remove(at: 0), at: 2)
        for index in 0...2 {
            buttonLayers[index].position = buttonLocations[index]
            buttonLayers[index].backgroundColor = UIColor.clear.cgColor
        }
        let selectedLayer = buttonLayers[selectedButtonIndex]
        self.layer.sublayers!.append(self.layer.sublayers!.remove(at: self.layer.sublayers!.index(of: selectedLayer)!))
        selectedLayer.backgroundColor = buttonColors[selectedButtonIndex].cgColor
        if(selectedButtonIndex == 0) {
            self.delegate?.onModeChange(newMode: .photo)
        }
        else if(selectedButtonIndex == 1) {
            self.delegate?.onModeChange(newMode: .video)
        }
        else if(selectedButtonIndex == 2) {
            self.delegate?.onModeChange(newMode: .layers)
        }
    }
    
    func wrapAroundOverBoundIndex(index: Int, maxSize: Int) -> Int {
        var value = index
        if(index > maxSize) {
            value = 0
            return value
        }
        else if(index < 0) {
            value = maxSize
            return value
        }
        else {
            return value
        }
    }
}
