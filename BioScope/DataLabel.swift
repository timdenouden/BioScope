//
//  DataLabel.swift
//  BioScope
//
//  Created by Timothy DenOuden on 7/22/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

class DataLabel {
    var pointOfInterest = CGPoint(x: 0.5, y: 0.5)
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    public func position(withParentSize parentSize: CGSize) -> CGPoint {
        return DataLabel.position(withParentSize: parentSize, atPointOfInterestRato: self.pointOfInterest)
    }
    
    public func layerForDrawing(withParentSize parentSize: CGSize) -> CALayer {
        let dotPath = UIBezierPath(ovalIn: CGRect(x: -4, y: -4, width: 8, height: 8))
        let dotLayer = CAShapeLayer()
        dotLayer.path = dotPath.cgPath
        dotLayer.fillColor = UIColor.white.cgColor
        dotLayer.strokeColor = UIColor.clear.cgColor
        dotLayer.lineWidth = 0.0
        return dotLayer
    }
    
    public static func position(withParentSize parentSize:CGSize, atPointOfInterestRato pointOfInterestRatio: CGPoint) -> CGPoint {
        return CGPoint(x: parentSize.width * pointOfInterestRatio.x, y: parentSize.height * pointOfInterestRatio.y)
    }
}
