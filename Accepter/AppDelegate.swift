//
//  AppDelegate.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 18/12/2019.
//  Copyright © 2019 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Swinject
import SwinjectAutoregistration
import Accepter_Mocks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var coordinator: AppCoordinator?
    static let container = Container()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppDelegate.initializeIocContainer()
        try! AppDelegate.container.resolve(LocalStorageService.self)?.initUsers()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = AppCoordinator(window: window!)
        coordinator?.start()
       
        window?.makeKeyAndVisible()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
        
        return true
    }
    
    private static func initializeIocContainer() {
        container.register(DialogService.self) { _ in DialogService() }
        container.autoregister(LocalStorageService.self, initializer: LocalStorageService.init).inObjectScope(.container)
        container.autoregister(AuthorizationService.self, initializer: AuthorizationService.init).inObjectScope(.container)
        container.autoregister(LoginViewModel.self, initializer: LoginViewModel.init)
        container.autoregister(HomeViewModel.self, initializer: HomeViewModel.init)
        container.autoregister(ExpenseViewModel.self, initializer: ExpenseViewModel.init)
        container.autoregister(ExpenseListViewModel.self, initializer: ExpenseListViewModel.init)
        container.autoregister(SettingsViewModel.self, initializer: SettingsViewModel.init)
    }
}

