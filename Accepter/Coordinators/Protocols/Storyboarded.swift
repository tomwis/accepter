//
//  Storyboarded.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 13/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate(fromStoryboard storyboardName: String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(fromStoryboard storyboardName: String) -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
