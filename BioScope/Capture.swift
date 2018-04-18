//
//  Capture.swift
//  BioScope
//
//  Created by Timothy DenOuden on 6/20/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//
//  Abstract superclass of captures handles capture data in a generic way

import UIKit

class Capture {
    
    var title: String
    var lensZoom: Int
    var imageDescription: String?
    var previewImage: UIImage?
    var id: Int = 0
    var dataLabels = [DataLabel]()
    var tags = [String]()
    
    init(title: String, zoom: Int) {
        self.title = title
        self.lensZoom = zoom
    }
    
    public func hasValidTitle() -> Bool {
        return (title.count > 0)
    }
    
    public func squarePreviewWith(width: CGFloat) -> UIImage {
        //if the preview doesnt exist, load it from filesystem and cache it to previewImage
        if let preview = previewImage {
            return preview
        }
        else {
            let onionFullResolution = UIImage(named: "onion")
            let scaledImage = ImageUtils.resize(image: onionFullResolution!, newWidth: width)
            previewImage = ImageUtils.centerCropSquare(image: scaledImage)
            return previewImage!
        }
    }
    
    public func releasePreview() {
        //if memory becomes an issue this is used to clear memory
        previewImage = nil
    }
}
