//
//  CGRect.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 05/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

extension CGRect {
    func expand(by border: CGFloat) -> CGRect {
        return CGRect(x: minX - border, y: minY - border, width: width + border * 2, height: height + border * 2)
    }
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        let origin = CGPoint(x: topLeft.x, y: topLeft.y)
        let size = CGSize(width: abs(topLeft.x - topRight.x), height: abs(topLeft.y - bottomLeft.y))
        self.init(origin: origin, size: size)
    }
}
