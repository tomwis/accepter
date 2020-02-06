//
//  ImageTextElement.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 05/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class ImageTextElement {
    init(topLeftPercent: CGPoint, topRightPercent: CGPoint, bottomLeftPercent: CGPoint, bottomRightPercent: CGPoint, imageSize: CGSize, text: String) {
        self.topLeftPercent = topLeftPercent
        self.topRightPercent = topRightPercent
        self.bottomLeftPercent = bottomLeftPercent
        self.bottomRightPercent = bottomRightPercent
        self.imageSize = imageSize
        self.text = text
    }
    
    let topLeftPercent: CGPoint
    let topRightPercent: CGPoint
    let bottomLeftPercent: CGPoint
    let bottomRightPercent: CGPoint
    let imageSize: CGSize
    let text: String
    var numberValue: Double?
    
    var x: CGFloat {
        topLeftPercent.x * imageSize.width
    }
    
    var y: CGFloat {
        (1 - topLeftPercent.y) * imageSize.height
    }
    
    var width: CGFloat {
        (topRightPercent.x - topLeftPercent.x) * imageSize.width
    }
    
    var height: CGFloat {
        (topLeftPercent.y - bottomLeftPercent.y) * imageSize.height
    }
    
    var topLeft: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    var topRight: CGPoint {
        CGPoint(x: x + width, y: y)
    }
    
    var bottomLeft: CGPoint {
        CGPoint(x: x, y: y + height)
    }
    
    var bottomRight: CGPoint {
        CGPoint(x: x + width, y: y + height)
    }
    
    var rect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}
