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
                
        MockUrlProtocol.apiUrls = [
            "baseUrl": AppSettings.baseUrl,
            "loginUrl": AppSettings.loginUrl,
            "userUrl": AppSettings.userUrl,
            "expensesUrl": AppSettings.expensesUrl,
            "expensesToApproveUrl": AppSettings.expensesToApproveUrl
        ]
        URLProtocol.registerClass(MockUrlProtocol.self)
        
        AppDelegate.initializeIocContainer()
        AppDelegate.container.resolve(LocalStorageService.self)!.checkMigrations()
        
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
        container.register(DocumentAnalysisService.self) { _ in DocumentAnalysisService() }
//        container.register(WebRequestService.self) { _ in UrlSessionWebRequestService() }
//            .initCompleted { (resolver, object) in
//                var o = object as! WebRequestService
//                o.authorizationService = resolver.resolve(AuthorizationService.self)
//        }
        container.register(WebRequestService.self) { _ in AlamofireWebRequestService(urlProtocol: MockUrlProtocol.self) }
            .initCompleted { (resolver, object) in
                var o = object as! WebRequestService
                o.authorizationService = resolver.resolve(AuthorizationService.self)
        }
        container.autoregister(LocalStorageService.self, initializer: LocalStorageService.init).inObjectScope(.container)
        container.autoregister(AuthorizationService.self, initializer: AuthorizationService.init).inObjectScope(.container)
        container.autoregister(ExpensesService.self, initializer: ExpensesService.init)
        container.autoregister(UserService.self, initializer: UserService.init)
        container.autoregister(FileService.self, initializer: FileService.init)
        container.autoregister(ImageService.self, initializer: ImageService.init)
        container.autoregister(CameraService.self, initializer: CameraService.init)
        container.autoregister(TextRecognitionService.self, initializer: TextRecognitionService.init)
        container.autoregister(LoginViewModel.self, initializer: LoginViewModel.init)
        container.autoregister(HomeViewModel.self, initializer: HomeViewModel.init)
        container.autoregister(ExpenseViewModel.self, initializer: ExpenseViewModel.init)
        container.autoregister(ExpenseListViewModel.self, initializer: ExpenseListViewModel.init)
        container.autoregister(SettingsViewModel.self, initializer: SettingsViewModel.init)
    }
}

