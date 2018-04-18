//
//  PreviewViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 4/24/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit
import AVFoundation
import VerticalSlider

class PreviewViewController: UIViewController, OnCaptureDelegate, AVCapturePhotoCaptureDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var modeToggleView: ModeToggleView!
    @IBOutlet weak var focusUpdateLabel: UILabel!
    @IBOutlet weak var focusSlider: VerticalSlider!
    
    private var editContainerView: EditContainerView?
    private var backCamera: AVCaptureDevice?
    private var session: AVCaptureSession?
    private var stillImageOutput: AVCapturePhotoOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    private var rotatedLayer: CAShapeLayer?
    
    @IBAction func focusButtonDidPress(_ sender: Any) {
        focusUpdateLabel.isHidden = !focusUpdateLabel.isHidden
        focusSlider.isHidden = !focusSlider.isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let previewView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.height))
        editContainerView = EditContainerView(frame: self.view.frame)
        editContainerView?.set(contentView: previewView, newMode: .preview)
        self.view.insertSubview(editContainerView!, at: 0)
        modeToggleView.delegate = self
        self.title = "Photo"
        setupPreview()
        
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        rotatedLayer = CAShapeLayer()
        rotatedLayer?.fillColor = nil
        rotatedLayer?.strokeColor = UIColor.red.cgColor
        rotatedLayer?.lineWidth = 2
        qrCodeFrameView?.layer.addSublayer(rotatedLayer!)
        
        editContainerView!.contentView!.addSubview(qrCodeFrameView!)
        editContainerView!.contentView!.bringSubview(toFront: qrCodeFrameView!)
        focusSlider.addTarget(self, action: #selector(focusSliderChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = editContainerView!.contentView!.bounds
        editContainerView?.contentToCenter(animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.destination is MarkupViewController) {
            let markupViewController : MarkupViewController = segue.destination as! MarkupViewController
            markupViewController.setImage(image: sender as! UIImage)
        }
    }
    
    func onCapture(mode: ModeToggleView.CaptureMode) {
        if(mode == .photo) {
            focusUpdateLabel.text = "Photo Captured!"
            focusUpdateLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.focusUpdateLabel.isHidden = true
            })
            UIView.animate(withDuration: 0.1, animations: {
                self.editContainerView!.contentView?.alpha = 0.2
            }, completion: {finished in
                self.editContainerView!.contentView?.alpha = 1
            })
            let settings = AVCapturePhotoSettings()
            settings.isHighResolutionPhotoEnabled = true
            let previewPixelType = settings.__availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [
                kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                kCVPixelBufferWidthKey as String: 160,
                kCVPixelBufferHeightKey as String: 160
            ]
            settings.previewPhotoFormat = previewFormat
            stillImageOutput?.capturePhoto(with: settings, delegate: self)
        }
        else if(mode == .layers) {
            editContainerView?.contentToCenter(animated: false)
        }
    }
    
    func onModeChange(newMode: ModeToggleView.CaptureMode) {
        if(newMode == .photo) {
            self.navigationItem.title = "Photo"
        }
        else if(newMode == .video) {
            self.navigationItem.title = "Video"
        }
        else if(newMode == .layers) {
            self.navigationItem.title = "Layers"
        }
    }
    
    @objc func focusSliderChanged() {
        if(focusSlider.value <= 0.01) {
            focusUpdateLabel.text = "Focus: Auto"
            changeFocusMode(to: AVCaptureDevice.FocusMode.autoFocus)
        }
        else {
            focusUpdateLabel.text = String(format: "Focus: %.0f", focusSlider.value * 100)
            changeFocus(to: focusSlider.value)
        }
    }
    
    // Start focus delegate
    func didReachTop() {
        changeFocus(to: 1)
        focusUpdateLabel.text = "Focus: ∞"
    }
    
    func didSliderValueChange(value: Float) {
        changeFocus(to: value)
        focusUpdateLabel.text = String(format: "Focus: %.0f", value * 100) + "%"
    }
    
    func didReachBottom() {
        changeFocusMode(to: AVCaptureDevice.FocusMode.autoFocus)
        focusUpdateLabel.text = "Focus: Auto"
    }
    
    func didShowAnimationBegin() {
        modeToggleView.isHidden = true
        focusUpdateLabel.isHidden = false
    }
    
    func didHideAnimationEnd() {
        modeToggleView.isHidden = false
        focusUpdateLabel.isHidden = true
    }
    // end focus delegate
    
    func didTap() {
        focusUpdateLabel.text = "Drag on circle to focus."
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let squareImageRect = CGRect(x: (cgImageRef.width - cgImageRef.height) / 2, y: 0, width: cgImageRef.height, height: cgImageRef.height)
            let squareCGImageRef = cgImageRef.cropping(to: squareImageRect)
            let image = UIImage(cgImage: squareCGImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
            
            let capture = PhotoCapture(title: "", zoom: Int(editContainerView!.zoomScale), image: image)
            CaptureStorageManager.save(capture: capture)
        } else {
            print("error capturing image")
        }
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if(metadataObjects == nil || metadataObjects.count == 0) {
            qrCodeFrameView?.frame = CGRect.zero
            focusUpdateLabel.isHidden = true
            focusUpdateLabel.text = ""
            rotatedLayer?.path = nil
        }
        else {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            print(metadataObject.corners)
            if(metadataObject.type == AVMetadataObject.ObjectType.qr) {
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
                
                qrCodeFrameView?.frame = barCodeObject.bounds
                let path = UIBezierPath()
                
                var startPoint = CGPoint(dictionaryRepresentation: metadataObject.corners[0] as! CFDictionary)
                startPoint!.x = startPoint!.x * qrCodeFrameView!.frame.width
                startPoint!.y = startPoint!.y * qrCodeFrameView!.frame.height
                path.move(to: startPoint!)
                for i in 1...metadataObject.corners.count - 1 {
                    var nextPoint = CGPoint(dictionaryRepresentation: metadataObject.corners[i] as! CFDictionary)
                    nextPoint!.x = nextPoint!.x * qrCodeFrameView!.frame.width
                    nextPoint!.y = nextPoint!.y * qrCodeFrameView!.frame.height
                    path.addLine(to: nextPoint!)
                }
                path.close()
                rotatedLayer?.path = path.cgPath
                
                if metadataObject.stringValue != nil {
                    focusUpdateLabel.isHidden = false
                    focusUpdateLabel.text = metadataObject.stringValue
                }
            }
        }
    }
    
    private func changeFocus(to value: Float) {
        do {
            try backCamera?.lockForConfiguration()
            backCamera?.setFocusModeLocked(lensPosition: value, completionHandler: {
                (time) -> Void in
                //stuff??
            })
            backCamera?.unlockForConfiguration()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func changeFocusMode(to mode: AVCaptureDevice.FocusMode) {
        do {
            try backCamera?.lockForConfiguration()
            backCamera?.focusMode = mode
            backCamera?.unlockForConfiguration()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupPreview() {
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        stillImageOutput = AVCapturePhotoOutput()
        stillImageOutput?.isHighResolutionCaptureEnabled = true
        
        backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            try backCamera?.lockForConfiguration()
            backCamera?.focusMode = AVCaptureDevice.FocusMode.locked
            backCamera?.unlockForConfiguration()
            input = try AVCaptureDeviceInput(device: backCamera!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            
            if(session!.canAddOutput(stillImageOutput!)) {
                let captureMetadataOutput = AVCaptureMetadataOutput()
                session?.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
                
                session!.addOutput(stillImageOutput!)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                editContainerView!.contentView?.layer.addSublayer(videoPreviewLayer!)
                session!.startRunning()
            }
        }
    }
}
