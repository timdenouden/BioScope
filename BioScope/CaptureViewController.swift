//
//  DisplayViewController.swift
//  BioScope
//
//  Created by Timothy DenOuden on 7/22/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, EditContainerViewDelegate {
    
    @IBOutlet weak var editContainerView: EditContainerView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    private let newLabelSegueIdentifier = "showNewLabel"
    private let newMeasurementSegueIdentifier = "showNewMeasurement"
    private let captureInfoSegueIdentifier = "showCaptureInfo"
    private let captureDetailsEditSegueIdentifier = "showEditCaptureDetails"
    
    public var capture: Capture!
    private var addReuseIdentifier = "AddLabelCell"
    private var labelReuseIdentifier = "DataLabelCell"
    private let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let labelFont = UIFont.systemFont(ofSize: 17.0)
    private var selectedRow = -1
    let greenColor = UIColor(red: 0.505, green: 0.823, blue: 0.089, alpha: 1.0)
    let redColor = UIColor.red
    
    @IBAction func rightBarButtonItemDidPress(_ sender: Any) {
        if(selectedRow == -1) {
            performSegue(withIdentifier: captureInfoSegueIdentifier, sender: nil)
        }
        else {
            let selectedDataLabel = capture.dataLabels[selectedRow - 1]
            if(selectedDataLabel is MeasurementDataLabel) {
                performSegue(withIdentifier: newMeasurementSegueIdentifier, sender: selectedDataLabel)
            }
            else {
                performSegue(withIdentifier: newLabelSegueIdentifier, sender: selectedDataLabel)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundView = nil
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = sectionInsets
        
        if capture is PhotoCapture {
            let photoCapure = capture as! PhotoCapture
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: editContainerView!.frame.width, height: editContainerView!.frame.width))
            imageView.image = photoCapure.image
            editContainerView.set(contentView: imageView, newMode: .photo)
        }
        editContainerView.editContainerDelegate = self
        editContainerView.contentToCenter(animated: false)
        self.title = capture.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedRow = -1
        updateDataLabelLines()
        editContainerView.zoom(to: editContainerView.contentView!.center, withScale: 1.0, animated: true)
        self.title = capture.title
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDataLabelLines()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            if(selectedRow == -1) {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Label", style: .default, handler: { _ in
                    self.performSegue(withIdentifier: self.newLabelSegueIdentifier, sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Measure", style: .default, handler: { _ in
                    self.performSegue(withIdentifier: self.newMeasurementSegueIdentifier, sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        else {
            if(selectedRow == indexPath.row) {
                clearLabelSelection()
                editContainerView.zoom(to: editContainerView.contentView!.center, withScale: 1.0, animated: true)
            }
            else {
                clearLabelSelection()
                selectedRow = indexPath.row
                rightBarButtonItem.title = "Edit"
                let cell = collectionView.cellForItem(at: indexPath) as! DataLabelViewCell
                cell.layer.backgroundColor = UIColor.white.cgColor
                cell.label.textColor = UIColor.darkText
                editContainerView.zoom(to: capture.dataLabels[indexPath.row - 1].position(withParentSize: editContainerView.contentView!.frame.size), withScale: 2.5, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capture.dataLabels.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.row == 0) {
            return CGSize(width: 40, height: 40)
        }
        else {
            let textAttributes = [NSAttributedStringKey.font: labelFont]
            let textString = capture.dataLabels[indexPath.row - 1].text as NSString
            return CGSize(width: textString.size(withAttributes: textAttributes).width + 16, height: 40) //the extra width accounts for desired padding of the cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.row == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addReuseIdentifier, for: indexPath)
            let shadowPath = UIBezierPath(ovalIn: cell.bounds)
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowPath = shadowPath.cgPath
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: labelReuseIdentifier, for: indexPath) as! DataLabelViewCell
            cell.index = indexPath.row - 1
            cell.label.text = capture.dataLabels[indexPath.row - 1].text
            cell.layer.cornerRadius = 8
            cell.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
            cell.label.textColor = UIColor.white
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateDataLabelLines()
    }
    
    func editContainerDidPan() {
        updateDataLabelLines()
    }
    
    private func clearLabelSelection() {
        selectedRow = -1
        rightBarButtonItem.title = "Info"
        if(capture.dataLabels.count > 0) {
            for row in 1...capture.dataLabels.count {
                if let cell = collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? DataLabelViewCell {
                    cell.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
                    cell.label.textColor = UIColor.white
                }
            }
        }
        
    }
    
    private func updateDataLabelLines() {
        if let overlayLayers = overlayView.layer.sublayers {
            for layer in overlayLayers {
                layer.removeFromSuperlayer()
            }
        }
        if(selectedRow == -1) {
            for cell in collectionView.visibleCells {
                if cell is DataLabelViewCell  {
                    let dataLabelCell = cell as! DataLabelViewCell
                    let topOfDataLabelCell = CGPoint(x: dataLabelCell.center.x, y: sectionInsets.top)
                    let dataLabelCellCenter = collectionView.convert(topOfDataLabelCell, to: collectionView.superview)
                    if let measureDataLabel = capture.dataLabels[dataLabelCell.index] as? MeasurementDataLabel {
                        let correspondingPointOfInterest = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: measureDataLabel.pointOfInterest), to: editContainerView!.superview)
                        let correspondingMeasureToPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: measureDataLabel.measureToPoint), to: editContainerView!.superview)
                        let midPointRatio = CGPoint(x: (measureDataLabel.measureToPoint.x + measureDataLabel.pointOfInterest.x) / 2, y: (measureDataLabel.measureToPoint.y + measureDataLabel.pointOfInterest.y) / 2)
                        let midPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: midPointRatio), to: editContainerView!.superview)
                        
                        let linePath = UIBezierPath()
                        linePath.move(to: dataLabelCellCenter)
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
                    else {
                        let dataLabel = capture.dataLabels[dataLabelCell.index]
                        let correspondingPointOfInterest = editContainerView!.convert(dataLabel.position(withParentSize: editContainerView!.contentView!.frame.size), to: editContainerView!.superview)
                        let linePath = UIBezierPath()
                        linePath.move(to: dataLabelCellCenter)
                        linePath.addLine(to: correspondingPointOfInterest)
                        let lineLayer = CAShapeLayer()
                        lineLayer.path = linePath.cgPath
                        lineLayer.lineCap = kCALineCapRound
                        lineLayer.lineWidth = 2
                        lineLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
                        lineLayer.fillColor = UIColor.clear.cgColor
                        overlayView.layer.addSublayer(lineLayer)
                        let dataPointLayer = dataLabel.layerForDrawing(withParentSize: editContainerView!.contentView!.frame.size)
                        dataPointLayer.position = correspondingPointOfInterest
                        overlayView.layer.addSublayer(dataPointLayer)
                    }
                }
            }
        }
        else {
            if let dataLabelCell = collectionView.cellForItem(at: IndexPath(row: selectedRow, section: 0)) as? DataLabelViewCell {
                let topOfDataLabelCell = CGPoint(x: dataLabelCell.center.x, y: sectionInsets.top)
                let dataLabelCellCenter = collectionView.convert(topOfDataLabelCell, to: collectionView.superview)
                if let measureDataLabel = capture.dataLabels[dataLabelCell.index] as? MeasurementDataLabel {
                    let correspondingPointOfInterest = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: measureDataLabel.pointOfInterest), to: editContainerView!.superview)
                    let correspondingMeasureToPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: measureDataLabel.measureToPoint), to: editContainerView!.superview)
                    let midPointRatio = CGPoint(x: (measureDataLabel.measureToPoint.x + measureDataLabel.pointOfInterest.x) / 2, y: (measureDataLabel.measureToPoint.y + measureDataLabel.pointOfInterest.y) / 2)
                    let midPoint = editContainerView.convert(DataLabel.position(withParentSize: editContainerView!.contentView!.frame.size, atPointOfInterestRato: midPointRatio), to: editContainerView!.superview)
                    
                    let linePath = UIBezierPath()
                    linePath.move(to: dataLabelCellCenter)
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
                else {
                    let dataLabel = capture.dataLabels[dataLabelCell.index]
                    let correspondingPointOfInterest = editContainerView!.convert(dataLabel.position(withParentSize: editContainerView!.contentView!.frame.size), to: editContainerView!.superview)
                    let linePath = UIBezierPath()
                    linePath.move(to: dataLabelCellCenter)
                    linePath.addLine(to: correspondingPointOfInterest)
                    let lineLayer = CAShapeLayer()
                    lineLayer.path = linePath.cgPath
                    lineLayer.lineCap = kCALineCapRound
                    lineLayer.lineWidth = 2
                    lineLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
                    lineLayer.fillColor = UIColor.clear.cgColor
                    overlayView.layer.addSublayer(lineLayer)
                    let dataPointLayer = dataLabel.layerForDrawing(withParentSize: editContainerView!.contentView!.frame.size)
                    dataPointLayer.position = correspondingPointOfInterest
                    overlayView.layer.addSublayer(dataPointLayer)
                }
            }
            
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == newLabelSegueIdentifier) {
            let newVC = segue.destination as! NewDataLabelViewController
            newVC.capture = capture
            if(sender != nil) {
                newVC.dataLabel = sender as? DataLabel
            }
            self.clearLabelSelection()
        }
        else if(segue.identifier == newMeasurementSegueIdentifier) {
            let newVC = segue.destination as! NewMeasurementDataLabelViewController
            newVC.capture = capture
            if(sender != nil) {
                newVC.measurementDataLabel = sender as? MeasurementDataLabel
            }
            self.clearLabelSelection()
        }
        else if(segue.identifier == captureInfoSegueIdentifier) {
            let newVC = segue.destination as! CaptureDetailsCollectionViewController
            newVC.capture = capture
            self.clearLabelSelection()
        }
    }

}
