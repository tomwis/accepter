//
//  ImagePickerHelper.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 06/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePickerHelper {
    static let dialogService = DialogService()
    
    static func openImagePicker(viewController: UIViewController, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
                                sourceType: UIImagePickerController.SourceType, animate: Bool = true, overlayView: UIView? = nil) -> UIImagePickerController? {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = delegate
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = false
            
            if sourceType == .camera {
                imagePickerController.cameraOverlayView = overlayView
            }
            viewController.present(imagePickerController, animated: animate)
            
            return imagePickerController
        } else {
            switch sourceType {
            case .camera:
                dialogService.showError(message: "Camera is not available")
            case .photoLibrary:
                dialogService.showError(message: "Photo library is not available")
            default:
                break
            }
        }
        
        return nil
    }
}
