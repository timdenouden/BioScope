//
//  MeasurementDataLabel.swift
//  BioScope
//
//  Created by Timothy DenOuden on 7/22/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

class MeasurementDataLabel: DataLabel {
    var measureToPoint = CGPoint(x: 0.5, y: 0.5)
    var distance: CGFloat {
        get {
            return sqrt(pow(measureToPoint.x - pointOfInterest.x, 2) + pow(measureToPoint.y - pointOfInterest.y, 2))
        }
    }
    
    public static func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }
}
