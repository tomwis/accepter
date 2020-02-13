//
//  ImageTextElement.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 05/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class ImageTextElement {
    init(textRect: CGRect, imageSize: CGSize, text: String) {
        self.textRectInPercent = textRect
        self.imageSize = imageSize
        self.text = text
    }
    
    let textRectInPercent: CGRect
    let imageSize: CGSize
    let text: String
    var numberValue: Double?
        
    var x: CGFloat {
        textRectInPercent.origin.x * imageSize.width
    }
    
    var y: CGFloat {
        (1 - textRectInPercent.origin.y) * imageSize.height
    }
    
    var width: CGFloat {
        textRectInPercent.width * imageSize.width
    }
    
    var height: CGFloat {
        textRectInPercent.height * imageSize.height
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
