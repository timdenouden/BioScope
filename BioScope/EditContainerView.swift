//
//  EditContainerView.swift
//  BioScope
//
//  Created by Timothy DenOuden on 4/23/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

@objc protocol EditContainerViewDelegate {
    @objc optional func editContainerDidBeginPan()
    @objc optional func editContainerDidPan()
    @objc optional func editContainerDidEndPan()
}

class EditContainerView: UIScrollView, UIScrollViewDelegate{
    enum DisplayMode {
        case preview
        case photo
        case video
        case layers
    }
    
    var mode = DisplayMode.preview
    var contentView: UIView?
    var editContainerDelegate: EditContainerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        self.backgroundColor = .clear
        self.delegate = self
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 10.0
    }
    
    public func set(contentView: UIView, newMode: DisplayMode) {
        let subViews = self.subviews
        for subview in subViews {
            subview.removeFromSuperview()
        }
        if(newMode == .preview) {
            self.mode = newMode
            self.contentView = contentView
            self.addSubview(contentView)
            self.setZoomScale(1.0, animated: true)
            self.minimumZoomScale = 1.0
        }
        else if (newMode == .photo) {
            self.mode = newMode
            self.contentView = contentView
            self.addSubview(contentView)
            self.setZoomScale(1.0, animated: true)
            self.minimumZoomScale = 1.0
        }
    }
    
    public func contentToCenter(animated: Bool) {
        if(self.mode == .preview) {
            let scrollToCenterPoint = CGPoint(x:(self.contentView!.frame.width - self.frame.width) / 2, y:(self.frame.height - self.contentView!.frame.height) / 2)
            
            self.setContentOffset(scrollToCenterPoint, animated: animated)
        }
        else if(self.mode == .photo) {
            let offsetX = max((self.frame.width - self.contentSize.width) * 0.5, 0)
            let offsetY = max((self.frame.height - self.contentSize.height) * 0.5, 0)
            self.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
        }
    }
    
    public func zoom(to point: CGPoint, withScale scale: CGFloat, animated: Bool) {
        if(animated) {
            UIView.animate(withDuration: 0.3, animations: {
                self.contentOffset.x = -((self.frame.width / 2) - point.x)
                self.contentOffset.y = -((self.frame.height / 2) - point.y)
                self.zoomScale = scale
            }, completion: { (completed: Bool) in
                
            })
        }
        else {
            self.contentOffset.x = -((self.frame.width / 2) - point.x)
            self.contentOffset.y = -((self.frame.height / 2) - point.y)
            self.zoomScale = scale
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        editContainerDelegate?.editContainerDidBeginPan?()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        editContainerDelegate?.editContainerDidPan?()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
            editContainerDelegate?.editContainerDidEndPan?()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        editContainerDelegate?.editContainerDidEndPan?()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if(self.mode == .photo) {
            contentToCenter(animated: false)
        }
        else if(self.mode == .preview) {
            
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //if(scale <= 1.0) {
        //    contentToCenter(animated: true)
        //}
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
