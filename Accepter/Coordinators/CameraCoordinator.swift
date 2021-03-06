//
//  CamerCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 06/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class CameraCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var rootViewController: UIViewController
    weak var parentCoordinator: Coordinator?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func start() {
        let vc = CameraViewController.instantiate(fromStoryboard: "Camera")
        vc.coordinator = self
        rootViewController = vc
    }
    
    func goToNewExpense(image: UIImage?) {
        if let parent = parentCoordinator as? MainCoordinator {
            parent.goToNewExpense(image: image)
        }
    }
    
    func returnToLastTab() {
        if let parent = parentCoordinator as? MainCoordinator {
            parent.returnToLastTab()
        }
    }
}
