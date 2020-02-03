//
//  ExpenseEditCoordinator.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 03/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

protocol ExpenseEditCoordinator: Coordinator {
    func goToAttachmentPreview(viewModel: ExpenseViewModel, filePath: URL, indexOnList: Int)
}

extension ExpenseEditCoordinator {
    func goToAttachmentPreview(viewModel: ExpenseViewModel, filePath: URL, indexOnList: Int) {
        let vc = AttachmentPreviewViewController.instantiate(fromStoryboard: "AttachmentPreview")
        vc.viewModel = viewModel
        vc.imageUrl = filePath
        vc.attachmentIndex = indexOnList
        
        if let nvc = rootViewController as? UINavigationController {
            nvc.pushViewController(vc, animated: true)
        }
    }
}
