//
//  DialogService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 22/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import SwiftMessages

class DialogService {
    func show(title: String?, body: String?, buttonTitle: String? = nil, buttonHandler: (() -> Void)? = nil, displayTimeInSeconds: Double = 10) {
        let view = MessageView.viewFromNib(layout: .cardView)
        var config = SwiftMessages.Config()
        config.duration = SwiftMessages.Duration.seconds(seconds: displayTimeInSeconds)
        config.presentationStyle = .bottom
        view.configureTheme(.info, iconStyle: .light)
        view.configureContent(title: title ?? "", body: body ?? "")
        
        if let buttonTitle = buttonTitle,
            let buttonHandler = buttonHandler {
            view.button?.setTitle(buttonTitle, for: .normal)
            view.buttonTapHandler = { (UIButton) -> Void in buttonHandler() }
        } else {
            view.button?.isHidden = true
        }
        
        SwiftMessages.show(config: config, view: view)
    }
    
    func showError(message: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        var config = SwiftMessages.Config()
        config.duration = SwiftMessages.Duration.seconds(seconds: 5)
        config.presentationStyle = .bottom
        view.configureTheme(.error, iconStyle: .light)
        view.configureContent(body: message)
        view.titleLabel?.isHidden = true
        view.button?.isHidden = true
                
        SwiftMessages.show(config: config, view: view)
    }
    
    func hide() {
        SwiftMessages.hide()
    }
}
