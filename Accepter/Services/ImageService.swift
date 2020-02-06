//
//  ImageService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 06/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    
    func getNewSizeForImage(currentSize: CGSize, newMaxSize: CGSize) -> CGSize {
        let aspectRatio = currentSize.width / currentSize.height
        var newWidth = newMaxSize.width
        var newHeight = newMaxSize.height
                    
        if aspectRatio > 1 {
            if currentSize.width < newMaxSize.width {
                newWidth = currentSize.width
            }
            
            newHeight = newWidth / aspectRatio
        } else {
            if currentSize.height < newMaxSize.height {
                newHeight = currentSize.height
            }
            
            newWidth = newHeight * aspectRatio
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return newSize
    }
    
    func getNewSizeForImage(currentSize: CGSize, lowerDimensionMaxSize: CGFloat) -> CGSize {
        let aspectRatio = currentSize.width / currentSize.height
        var newWidth = currentSize.width
        var newHeight = currentSize.height
                    
        if aspectRatio > 1 {
            // Width > Height
            if newHeight <= lowerDimensionMaxSize {
                return currentSize
            }
            
            newHeight = lowerDimensionMaxSize
            newWidth = newHeight * aspectRatio
        } else {
            // Height > Width
            if newWidth <= lowerDimensionMaxSize {
                return currentSize
            }
            
            newWidth = lowerDimensionMaxSize
            newHeight = newWidth / aspectRatio
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return newSize
    }
    
    func resizeImage(image: UIImage, lowerDimensionMaxSize: CGFloat, opaque: Bool) -> UIImage? {
        let size = getNewSizeForImage(currentSize: image.size, lowerDimensionMaxSize: lowerDimensionMaxSize)
        
        return resize(image: image, newSize: size, opaque: opaque)
    }
    
    func resizeImage(image: UIImage, newMaxSize: CGSize, opaque: Bool) -> UIImage? {
        let size = getNewSizeForImage(currentSize: image.size, newMaxSize: newMaxSize)
        
        return resize(image: image, newSize: size, opaque: opaque)
    }
    
    private func resize(image: UIImage, newSize: CGSize, opaque: Bool) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, opaque, 1.0)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
