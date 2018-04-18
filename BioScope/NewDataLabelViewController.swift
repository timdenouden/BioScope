//
//  NewDataLabelViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 7/25/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class NewDataLabelViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, EditContainerViewDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editContainerView: EditContainerView!
    @IBOutlet weak var deleteBarButtonItem: UINavigationItem!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setPointButtonVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var setPointButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var capture: Capture!
    var dataLabel: DataLabel?
    var pointOfInterestRatio: CGPoint!
    var isKeyboardShown = false
    var isCursorPanning = false
    let cursorDotLayer = CAShapeLayer()
    
    @IBAction func deleteButtonDidPress(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Label", style: .destructive, handler: { _ in
            if(self.dataLabel != nil) {
                self.capture.dataLabels = self.capture.dataLabels.filter{$0 !== self.dataLabel!}
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func setButtonDidPress(_ sender: UIButton) {
        textField.text = ""
        pointOfInterestRatio = getPointOfInterestRatioFromCursor()
        enableTextFieldWithKeyboard()
        enableSaveButtonIfValid()
    }
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        if(dataLabel != nil) {
            dataLabel?.text = textField.text!
            dataLabel?.pointOfInterest = pointOfInterestRatio
        }
        else {
            let tempDataLabel = DataLabel(text: textField.text!)
            tempDataLabel.pointOfInterest = pointOfInterestRatio
            capture.dataLabels.append(tempDataLabel)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        enableSaveButtonIfValid()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(NewDataLabelViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewDataLabelViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if capture is PhotoCapture {
            let photoCapure = capture as! PhotoCapture
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: editContainerView!.frame.width, height: editContainerView!.frame.width))
            imageView.image = photoCapure.image
            editContainerView.set(contentView: imageView, newMode: .photo)
        }
        if(dataLabel != nil) {
            textField.text = dataLabel!.text
            textField.isEnabled = true
            textField.isHidden = false
            pointOfInterestRatio = CGPoint(x: dataLabel!.pointOfInterest.x, y: dataLabel!.pointOfInterest.y)
        }
        editContainerView.decelerationRate = UIScrollViewDecelerationRateFast
        editContainerView.editContainerDelegate = self
        editContainerView.contentToCenter(animated: false)
        editContainerView.zoomScale = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewDataLabelViewController.editContainerViewTap(sender:)))
        tapGesture.delegate = self
        editContainerView.addGestureRecognizer(tapGesture)
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
        let triangleLayer = CAShapeLayer()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.lineJoin = kCALineJoinRound
        triangleLayer.lineWidth = 2
        let orangeColor = UIColor(red: 0.945, green: 0.643, blue: 0.047, alpha: 1.0)
        triangleLayer.strokeColor = orangeColor.cgColor
        triangleLayer.fillColor = orangeColor.cgColor
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
        super.viewDidAppear(animated)
        drawLineToPointOfInterest()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShown = true
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        editContainerViewBottomConstraint.constant = keyboardFrame.height
        overlayViewBottomConstraint.constant = keyboardFrame.height
        textFieldBottomConstraint.constant = keyboardFrame.height + 8
        saveButtonBottomConstraint.constant = keyboardFrame.height + 8
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.overlayView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
            self.cursorDotLayer.fillColor = UIColor.clear.cgColor
            //self.cursorDotLayer.position = self.overlayView.center
            self.editContainerView.contentOffset.y = self.editContainerView.contentOffset.y + (keyboardFrame.height / 2)
            self.drawLineToPointOfInterest()
            }, completion: { (finished) in
                //self.drawLineToPointOfInterest()
                })
        enableSaveButtonIfValid()
    }
    
    @objc func keyboardWillHide(notification: NSNotification?) {
        isKeyboardShown = false
        editContainerViewBottomConstraint.constant = 0
        overlayViewBottomConstraint.constant = 0
        textFieldBottomConstraint.constant = 8
        saveButtonBottomConstraint.constant = 8
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.overlayView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
            self.cursorDotLayer.fillColor = UIColor.white.cgColor
            //self.cursorDotLayer.position = self.overlayView.center
            self.drawLineToPointOfInterest()
        }, completion: { (finished) in
            self.enableSetPointButtonIfValid()
        })
        enableSaveButtonIfValid()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func editContainerViewTap(sender: UITapGestureRecognizer) {
        if(isKeyboardShown) {
            textField.resignFirstResponder()
        }
    }
    
    func editContainerDidBeginPan() {
        isCursorPanning = true
    }
    
    func editContainerDidPan() {
        drawLineToPointOfInterest()
        enableSetPointButtonIfValid()
    }
    
    func editContainerDidEndPan() {
        isCursorPanning = false
        enableSetPointButtonIfValid()
    }
    
    func enableTextFieldWithKeyboard() {
        textField.isEnabled = true
        textField.isHidden = false
        enableSetPointButtonIfValid()
        textField.becomeFirstResponder()
    }
    
    func isDataReadyToSave() -> Bool {
        if let text = textField.text {
            return (pointOfInterestRatio != nil && text.count > 0)
        }
        return false
    }
    
    func enableSetPointButtonIfValid() {
        if( !isKeyboardShown && !isCursorPanning) {
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
    }
    
    func enableSaveButtonIfValid() {
        if(isDataReadyToSave()) {
            saveButton.isEnabled = true
            saveButton.isHidden = false
        }
        else {
            saveButton.isEnabled = false
            saveButton.isHidden = true
        }
    }
    
    func getPointOfInterestRatioFromCursor() -> CGPoint {
        var pointOfInterest = overlayView.convert(overlayView.center, to: editContainerView!.contentView)
        pointOfInterest.x = (pointOfInterest.x * editContainerView.zoomScale) / editContainerView.contentView!.frame.width
        pointOfInterest.y = (pointOfInterest.y * editContainerView.zoomScale) / editContainerView.contentView!.frame.height
        return pointOfInterest
    }
    
    func drawLineToPointOfInterest() {
        if let overlayLayers = overlayView.layer.sublayers {
            for layer in overlayLayers {
                if(layer != cursorDotLayer) {
                    layer.removeFromSuperlayer()
                }
            }
        }
        if(pointOfInterestRatio != nil) {
            //let topOfTextField = CGPoint(x: textField.center.x, y: 8)
            let dataLabelCellCenter = CGPoint(x: 8 + textField.frame.width / 2, y: overlayView.frame.height - 8 - 40)
            let correspondingPointOfInterest = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: pointOfInterestRatio), to: editContainerView!.superview)
            let linePath = UIBezierPath()
            linePath.move(to: dataLabelCellCenter)
            linePath.addLine(to: correspondingPointOfInterest)
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineCap = kCALineCapRound
            lineLayer.lineWidth = 2
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            overlayView.layer.addSublayer(lineLayer)
            let dotPath = UIBezierPath(ovalIn: CGRect(x: -4, y: -4, width: 8, height: 8))
            let dotLayer = CAShapeLayer()
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = UIColor.white.cgColor
            dotLayer.strokeColor = UIColor.clear.cgColor
            dotLayer.lineWidth = 0.0
            dotLayer.position = correspondingPointOfInterest
            overlayView.layer.addSublayer(dotLayer)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
