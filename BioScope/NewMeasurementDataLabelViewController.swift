//
//  NewMeasurementDataLabelViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 11/3/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class NewMeasurementDataLabelViewController: UIViewController, EditContainerViewDelegate {
    enum SetMode {
        case A
        case B
    }
    
    @IBOutlet weak var editContainerView: EditContainerView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var setPointButton: UIButton!
    @IBOutlet weak var setPointButtonVerticalCenterConstraint: NSLayoutConstraint!
    
    var capture : Capture!
    var measurementDataLabel : MeasurementDataLabel?
    var isCursorPanning = false
    var mode = SetMode.A
    let cursorDotLayer = CAShapeLayer()
    let triangleLayer = CAShapeLayer()
    let greenColor = UIColor(red: 0.505, green: 0.823, blue: 0.089, alpha: 1.0)
    let redColor = UIColor.red
    
    private var pointOfInterestRatio : CGPoint!
    private var measureToPointRatio : CGPoint!
    
    @IBAction func setPointButtonDidPress(_ sender: Any) {
        if(mode == SetMode.A) {
            measureToPointRatio = nil
            pointOfInterestRatio = getPointOfInterestRatioFromCursor()
        }
        else if(mode == SetMode.B) {
            measureToPointRatio = getPointOfInterestRatioFromCursor()
        }
        updateMeasurementLabel()
        enableSaveButtonIfValid()
        updateMode()
        updateSetPointButton()
        drawLines()
    }
    
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        if(measurementDataLabel != nil) {
            measurementDataLabel?.text = measurementLabel.text!
            measurementDataLabel?.pointOfInterest = pointOfInterestRatio
            measurementDataLabel?.measureToPoint = measureToPointRatio
        }
        else {
            let tempDataLabel = MeasurementDataLabel(text: measurementLabel.text!)
            tempDataLabel.pointOfInterest = pointOfInterestRatio
            tempDataLabel.measureToPoint = measureToPointRatio
            capture.dataLabels.append(tempDataLabel)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonDidPress(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Measurement", style: .destructive, handler: { _ in
            if(self.measurementDataLabel != nil) {
                self.capture.dataLabels = self.capture.dataLabels.filter{$0 !== self.measurementDataLabel!}
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        if capture is PhotoCapture {
            let photoCapure = capture as! PhotoCapture
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: editContainerView!.frame.width, height: editContainerView!.frame.width))
            imageView.image = photoCapure.image
            editContainerView.set(contentView: imageView, newMode: .photo)
        }
        if(measurementDataLabel != nil) {
            measurementLabel.text = measurementDataLabel!.text
            measurementLabel.isEnabled = true
            measurementLabel.isHidden = false
            pointOfInterestRatio = CGPoint(x: measurementDataLabel!.pointOfInterest.x, y: measurementDataLabel!.pointOfInterest.y)
            measureToPointRatio = CGPoint(x: measurementDataLabel!.measureToPoint.x, y: measurementDataLabel!.measureToPoint.y)
        }
        editContainerView.decelerationRate = UIScrollViewDecelerationRateFast
        editContainerView.editContainerDelegate = self
        editContainerView.contentToCenter(animated: false)
        editContainerView.zoomScale = 2
        let dotPath = UIBezierPath(ovalIn: CGRect(x: -4, y: -4, width: 8, height: 8))
        cursorDotLayer.path = dotPath.cgPath
        cursorDotLayer.fillColor = UIColor.white.cgColor
        cursorDotLayer.strokeColor = UIColor.clear.cgColor
        cursorDotLayer.lineWidth = 0.0
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: 0, y: -4))
        trianglePath.addLine(to: CGPoint(x: 4, y: 0))
        trianglePath.addLine(to: CGPoint(x: -4, y: 0))
        trianglePath.close()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.lineJoin = kCALineJoinRound
        triangleLayer.lineWidth = 2
        triangleLayer.strokeColor = greenColor.cgColor
        triangleLayer.fillColor = greenColor.cgColor
        triangleLayer.position = CGPoint(x: setPointButton.layer.frame.width / 2 ,y: 0)
        setPointButton.layer.addSublayer(triangleLayer)
        let shadowPath = UIBezierPath(rect: setPointButton.bounds)
        setPointButton.layer.masksToBounds = false
        setPointButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
        setPointButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        setPointButton.layer.shadowOpacity = 0.5
        setPointButton.layer.shadowPath = shadowPath.cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        enableSaveButtonIfValid()
        cursorDotLayer.position = overlayView.center
        if let overlayLayers = overlayView.layer.sublayers {
            for layer in overlayLayers {
                if(layer != cursorDotLayer) {
                    layer.removeFromSuperlayer()
                }
            }
        }
        overlayView.layer.addSublayer(cursorDotLayer)
        drawLines()
    }
    
    func editContainerDidBeginPan() {
        isCursorPanning = true
    }
    
    func editContainerDidPan() {
        drawLines()
        updateSetPointButton()
    }
    
    func editContainerDidEndPan() {
        isCursorPanning = false
        updateSetPointButton()
    }
    
    private func isDataReadyToSave() -> Bool {
        return (pointOfInterestRatio != nil && measureToPointRatio != nil)
    }
    
    private func updateMode() {
        if(mode == SetMode.A) {
            mode = SetMode.B
        }
        else if(mode == SetMode.B) {
            mode = SetMode.A
        }
    }
    
    private func updateSetPointButton() {
        if(!isCursorPanning) {
            setPointButtonVerticalCenterConstraint.constant = 32
            setPointButton.isEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                self.setPointButton.alpha = 1
            })
        }
        else {
            setPointButtonVerticalCenterConstraint.constant = 64
            setPointButton.isEnabled = false;
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                self.setPointButton.alpha = 0.3
            })
        }
        if(mode == SetMode.A) {
            setPointButton.backgroundColor = greenColor
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            triangleLayer.fillColor = greenColor.cgColor
            triangleLayer.strokeColor = greenColor.cgColor
            CATransaction.commit()
            setPointButton.setTitle("Set A", for: .normal)
        }
        else if(mode == SetMode.B) {
            setPointButton.backgroundColor = redColor
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            triangleLayer.fillColor = redColor.cgColor
            triangleLayer.strokeColor = redColor.cgColor
            CATransaction.commit()
            setPointButton.setTitle("Set B", for: .normal)
        }
    }
    
    private func updateMeasurementLabel() {
        if(pointOfInterestRatio != nil && measureToPointRatio != nil) {
            measurementLabel.isHidden = false
            measurementLabel.text = String(format: "%.1f", Double(MeasurementDataLabel.distance(from: pointOfInterestRatio, to: measureToPointRatio) * (editContainerView.contentView?.frame.width)!)) + " px"
        }
        else {
            measurementLabel.isHidden = true
        }
    }
    
    private func enableSaveButtonIfValid() {
        if(isDataReadyToSave()) {
            saveButton.isEnabled = true
            saveButton.isHidden = false
        }
        else {
            saveButton.isEnabled = false
            saveButton.isHidden = true
        }
    }
    
    private func getPointOfInterestRatioFromCursor() -> CGPoint {
        var pointOfInterest = overlayView.convert(overlayView.center, to: editContainerView!.contentView)
        pointOfInterest.x = (pointOfInterest.x * editContainerView.zoomScale) / editContainerView.contentView!.frame.width
        pointOfInterest.y = (pointOfInterest.y * editContainerView.zoomScale) / editContainerView.contentView!.frame.height
        return pointOfInterest
    }
    
    private func drawLines() {
        if let overlayLayers = overlayView.layer.sublayers {
            for layer in overlayLayers {
                if(layer != cursorDotLayer) {
                    layer.removeFromSuperlayer()
                }
            }
        }
        if(pointOfInterestRatio != nil && measureToPointRatio != nil) {
            let measurementLabelCenter = CGPoint(x: 8 + measurementLabel.frame.width / 2, y: overlayView.frame.height - 8 - 40)
            let correspondingPointOfInterest = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: pointOfInterestRatio), to: editContainerView!.superview)
            let correspondingMeasureToPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: measureToPointRatio), to: editContainerView!.superview)
            let midPointRatio = CGPoint(x: (measureToPointRatio.x + pointOfInterestRatio.x) / 2, y: (measureToPointRatio.y + pointOfInterestRatio.y) / 2)
            let midPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: midPointRatio), to: editContainerView!.superview)
            
            let linePath = UIBezierPath()
            linePath.move(to: measurementLabelCenter)
            linePath.addLine(to: midPoint)
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineCap = kCALineCapRound
            lineLayer.lineWidth = 2
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            overlayView.layer.addSublayer(lineLayer)
            
            let measureLinePath = UIBezierPath()
            measureLinePath.move(to: correspondingPointOfInterest)
            measureLinePath.addLine(to: correspondingMeasureToPoint)
            let measurementLineLayer = CAShapeLayer()
            measurementLineLayer.path = measureLinePath.cgPath
            measurementLineLayer.lineCap = kCALineCapRound
            measurementLineLayer.lineWidth = 2
            let dashPattern : [NSNumber] = [3, 3]
            measurementLineLayer.lineDashPattern = dashPattern
            measurementLineLayer.strokeColor = UIColor.white.cgColor
            measurementLineLayer.fillColor = UIColor.clear.cgColor
            overlayView.layer.addSublayer(measurementLineLayer)
            
            let dotPath = UIBezierPath(ovalIn: CGRect(x: -4, y: -4, width: 8, height: 8))
            let dotALayer = CAShapeLayer()
            dotALayer.path = dotPath.cgPath
            dotALayer.fillColor = greenColor.cgColor
            dotALayer.strokeColor = UIColor.clear.cgColor
            dotALayer.lineWidth = 0.0
            dotALayer.position = correspondingPointOfInterest
            overlayView.layer.addSublayer(dotALayer)
            
            let dotBLayer = CAShapeLayer()
            dotBLayer.path = dotPath.cgPath
            dotBLayer.fillColor = redColor.cgColor
            dotBLayer.strokeColor = UIColor.clear.cgColor
            dotBLayer.lineWidth = 0.0
            dotBLayer.position = correspondingMeasureToPoint
            overlayView.layer.addSublayer(dotBLayer)
        }
        else if(pointOfInterestRatio != nil) {
            let correspondingPointOfInterest = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: pointOfInterestRatio), to: editContainerView!.superview)
            let tempMeasureToPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: getPointOfInterestRatioFromCursor()), to: editContainerView!.superview)
            
            let linePath = UIBezierPath()
            linePath.move(to: correspondingPointOfInterest)
            linePath.addLine(to: tempMeasureToPoint)
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineCap = kCALineCapRound
            lineLayer.lineWidth = 2
            let dashPattern : [NSNumber] = [3, 3]
            lineLayer.lineDashPattern = dashPattern
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            overlayView.layer.addSublayer(lineLayer)
            
            let dotPath = UIBezierPath(ovalIn: CGRect(x: -4, y: -4, width: 8, height: 8))
            let dotLayer = CAShapeLayer()
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = greenColor.cgColor
            dotLayer.strokeColor = UIColor.clear.cgColor
            dotLayer.lineWidth = 0.0
            dotLayer.position = correspondingPointOfInterest
            overlayView.layer.addSublayer(dotLayer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
