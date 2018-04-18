//
//  MarkupViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 3/19/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class MarkupViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    @IBAction func didEnhanceButtonPress(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: "Enhance", message: "Enhance or modify image to isolate cell structures", preferredStyle: .actionSheet)
        let cannyAction = UIAlertAction(title: "Edge Detect", style: .default) { _ in
            self.activityIndicatorView.startAnimating()
            var dstImage : UIImage?
            DispatchQueue.global().async {
                //dstImage = OpenCVWrapper.cvEdgeDetect(self.editCaptureView?.getImage()!)
                
                DispatchQueue.main.async(execute: {
                    if dstImage != nil {
                        self.setImage(image: dstImage!)
                        if(self.captureView != nil) {
                            self.editCaptureView?.set(contentView: self.captureView!, newMode: .photo)
                        }
                        self.activityIndicatorView.stopAnimating()
                    }
                    else {
                        self.activityIndicatorView.stopAnimating()
                        print("Error occurred")
                    }
                })
            }
        }
        sheet.addAction(cannyAction)
        
        let sharpenAction = UIAlertAction(title: "Sharpen", style: .default)
        { _ in
            self.activityIndicatorView.startAnimating()
            var dstImage : UIImage?
            DispatchQueue.global().async {
                //dstImage = OpenCVWrapper.cvSharpen(self.editCaptureView?.getImage()!)
                
                DispatchQueue.main.async(execute: {
                    if dstImage != nil {
                        self.setImage(image: dstImage!)
                        if(self.captureView != nil) {
                            self.editCaptureView?.set(contentView: self.captureView!, newMode: .photo)
                        }
                        self.activityIndicatorView.stopAnimating()
                    }
                    else {
                        self.activityIndicatorView.stopAnimating()
                        print("Error occurred")
                    }
                })
            }
        }
        sheet.addAction(sharpenAction)
        
        let countAction = UIAlertAction(title: "Threshold", style: .default)
        { _ in
            self.activityIndicatorView.startAnimating()
            var dstImage : UIImage?
            DispatchQueue.global().async {
                //dstImage = OpenCVWrapper.cvSmooth(self.editCaptureView?.getImage()!)
                
                DispatchQueue.main.async(execute: {
                    if dstImage != nil {
                        self.setImage(image: dstImage!)
                        if(self.captureView != nil) {
                            self.editCaptureView?.set(contentView: self.captureView!, newMode: .photo)
                        }
                        self.activityIndicatorView.stopAnimating()
                    }
                    else {
                        self.activityIndicatorView.stopAnimating()
                        print("Error occurred")
                    }
                })
            }
        }
        sheet.addAction(countAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func didFilterButtonPress(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func didBrightnessButtonPress(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func didMeasureButtonPress(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func didShareButtonPress(_ sender: UIBarButtonItem) {
        
    }
    
    
    var editCaptureView: EditContainerView?
    var captureView: UIView?
    var captureImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        editCaptureView = EditContainerView(frame:frame)
        let tempView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width))
        tempView.image = captureImage
        captureView = tempView
        editCaptureView?.set(contentView: captureView!, newMode: .photo)
        self.view.insertSubview(editCaptureView!, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //editCaptureView?.contentToCenter()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func setImage(image: UIImage) {
        captureImage = image;
    }
}
