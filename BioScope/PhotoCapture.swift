//
//  PhotoCapture.swift
//  BioScope
//
//  Created by Timothy DenOuden on 4/5/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

// class will encapsulate a capture so the main image, preview image, array of measurements and
class PhotoCapture : Capture {
    
    var image: UIImage
    
    init(title: String, zoom: Int, image: UIImage) {
        self.image = image
        super.init(title: title, zoom: zoom)
    }
    
    override public func squarePreviewWith(width: CGFloat) -> UIImage {
        if let preview = previewImage {
            return preview
        }
        else {
            previewImage = ImageUtils.resize(image: image, newWidth: width * 2)
            return previewImage!
        }
    }
}
