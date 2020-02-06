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
        return CGRect(x: minX - border, y: minY - border, width: width + border, height: height + border)
    }
}
