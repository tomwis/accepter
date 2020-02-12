//
//  MainViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, Storyboarded, UITabBarControllerDelegate {

    var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    override var selectedIndex: Int {
        willSet {
            if let viewControllers = viewControllers {
                _ = animateTabTransition(newViewController: viewControllers[newValue])

                updateUI(viewController: viewControllers[newValue])
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vc = viewController as? UINavigationController {
            vc.popToRootViewController(animated: false)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if !viewController.isKind(of: CameraViewController.self),
            let index = viewControllers?.firstIndex(of: viewController) {
            coordinator?.previousTabIndex = index
        }
        
        updateUI(viewController: viewController)
        
        return animateTabTransition(newViewController: viewController)
    }
    
    private func updateUI(viewController: UIViewController) {
        if let child = viewController as? TabBarChildController {
            tabBar.isHidden = !child.showTabBar
        } else if let navVc = viewController as? UINavigationController,
            let child = navVc.topViewController as? TabBarChildController {
            tabBar.isHidden = !child.showTabBar
        }
    }
    
    private func animateTabTransition(newViewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view,
            let toView = newViewController.view else {
                return false
        }
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.1, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}
