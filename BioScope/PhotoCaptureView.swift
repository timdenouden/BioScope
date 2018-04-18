//
//  PhotoCaptureView.swift
//  BioScope
//
//  Created by Timothy DenOuden on 3/19/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class PhotoCaptureView: UIView, UIGestureRecognizerDelegate {
    
    var imageView : UIImageView?
    var selectedView: UIView?
    var maxScale = CGFloat(10.0)
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame:frame)
        setupSubviews()
        setImage(image: image)
    }
    
    private func setupSubviews() {
        self.backgroundColor = .blue
        
        imageView = UIImageView(frame: frame)
        imageView?.alpha = 0.5
        imageView?.isUserInteractionEnabled = true
        addSubview(imageView!)
        
        let smallFrame = CGRect(x: 10, y: 10, width: 44, height: 44)
        let iconView = UIImageView(frame: smallFrame)
        iconView.isUserInteractionEnabled = true
        iconView.image = UIImage(named: "ic_center_focus_weak_white")
        addSubview(iconView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PhotoCaptureView.onPan(sender:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(PhotoCaptureView.onPinch(sender:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
    }
    
    public func setImage(image: UIImage) {
        imageView?.image = image
    }
    
    @objc func onPan(sender: UIPanGestureRecognizer) {
        if(sender.state == .began || sender.state == .changed) {
            let translation = sender.translation(in: self.superview)
            self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
            sender.setTranslation(.zero, in: self.superview)
        }
        
    }
    
    @objc func onPinch(sender: UIPinchGestureRecognizer) {
        if(sender.state == .began || sender.state == .changed) {
            //test to ensure this view is not smaller than the parent view
            self.transform = self.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1.0
        }
        else {
            ensureFrame()
        }
    }
    
    private func ensureFrame() {
        //first ensure size
        //if self is beyond the maximum allowed size
        if(self.frame.width > self.superview!.frame.width * maxScale || self.frame.height > self.superview!.frame.height * maxScale) {
            //reset to maxSize
            self.scaleRelativeToSuperView(toScale: maxScale)
        }
        //if self is beyond the minimum allowed size
        else if(self.frame.width < self.superview!.frame.width || self.frame.height < self.superview!.frame.height) {
            //reset to minSize
            self.scaleRelativeToSuperView(toScale: CGFloat(1.0))
        }
        
        //next ensure location
        //
    }
    
    private func scaleRelativeToSuperView(toScale scale: CGFloat) {
        self.imageView!.frame.size = CGSize(width: self.superview!.frame.width * scale, height: self.superview!.frame.height * scale)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
