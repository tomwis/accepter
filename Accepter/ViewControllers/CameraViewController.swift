//
//  CameraViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 06/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, Storyboarded {
    
    var coordinator: CameraCoordinator?
    var dismissing = false
        
    override func viewWillAppear(_ animated: Bool) {
        if !dismissing && ImagePickerHelper.isCameraAccessAuthorized() {
            ImagePickerHelper.openImagePicker(viewController: self, delegate: self, sourceType: .camera)
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            dismissing = true
            self.coordinator?.goToNewExpense(image: image)
            picker.dismiss(animated: true) {
                self.dismissing = false
            }
        }        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissing = true
        self.coordinator?.returnToLastTab()
        dismiss(animated: true) {
            self.dismissing = false
        }
    }
}
