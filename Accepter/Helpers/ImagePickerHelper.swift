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
                                sourceType: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = delegate
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = false
            viewController.present(imagePickerController, animated: true)
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
    }
    
    static func isCameraAccessAuthorized() -> Bool {
        let cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraPermission {
        case .notDetermined, .authorized:
            return true
        case .restricted, .denied:
            dialogService.show(title: "Camera access", body: "Access to camera was denied. Open settings to allow camera access.", buttonTitle: "Settings", buttonHandler: openSettings, displayTimeInSeconds: 10)
            return false
        default:
            return false
        }
    }
    
    static func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}
