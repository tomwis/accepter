//
//  Coordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 13/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var childCoordinators: [Coordinator] { get set }
    var rootViewController: UIViewController { get }
    var parentCoordinator: Coordinator? { get set }
    func start()
}
