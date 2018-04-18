//
//  ImageUtils.swift
//  BioScope
//
//  Created by Timothy DenOuden on 6/20/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class ImageUtils {
    public static func resize(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public static func centerCropSquare(image: UIImage) -> UIImage {
        var squareImageRect: CGRect
        if(image.size.width > image.size.height) {
            squareImageRect = CGRect(x: (image.size.width - image.size.height) / 2, y: 0, width: image.size.height, height: image.size.height)
        }
        else {
            squareImageRect = CGRect(x: 0, y: (image.size.height - image.size.width) / 2, width: image.size.width, height: image.size.width)
        }
        let squareCGImageRef = image.cgImage!.cropping(to: squareImageRect)
        return UIImage(cgImage: squareCGImageRef!, scale: 1.0, orientation: UIImageOrientation.up)
    }
    
    public static func rotate(image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
}
