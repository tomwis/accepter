//
//  CameraViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 06/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class CameraViewController: UIViewController, Storyboarded, TabBarChildController {
        
    @IBOutlet weak var scanTitleLabel: UILabel!
    @IBOutlet weak var scanValueLabel: UILabel!
    @IBOutlet weak var videoPreviewView: VideoPreviewView!
    @IBOutlet weak var valuePreviewViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var valuePreviewView: UIView!
    @IBOutlet weak var switchModeButton: UIButton!
    @IBOutlet weak var cameraButtonContainer: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    let cameraService = AppDelegate.container.resolve(CameraService.self)!
    let textRecognitionService = AppDelegate.container.resolve(TextRecognitionService.self)!
    let documentAnalysisService = AppDelegate.container.resolve(DocumentAnalysisService.self)!

    let switchModeButtonConfig = UIImage.SymbolConfiguration(pointSize: 21)
    
    var coordinator: CameraCoordinator?
    var isImagePickerDismissing = false
    var isTextRecognitionActive = false
    var currentFieldType = FieldName.Expense.amount
    var selectedTexts = [FieldName.Expense: String]()
    var isValueScanningModeSelected = true
    var imagePickerController: UIImagePickerController?
    var flashButton: UIButton?
    
    var showTabBar: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        if !isImagePickerDismissing {
            cameraButtonContainer.addArrangedSubview(videoPreviewView.cameraButton)
            videoPreviewView.cameraButtonTapped = cameraButtonTapped
            initStyles()
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                cameraService.setupCamera(videoPreviewView, delegate: self)
                
                cameraService.isCameraAccessAuthorized { accessGranted in
                    if accessGranted {
                        self.updateCameraMode()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        selectedTexts.removeAll()
        scanValueLabel.text = nil
        coordinator?.returnToLastTab()
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        let defaults = UserDefaults.standard

        // remove old values
        for value in FieldName.Expense.allCases {
            defaults.removeObject(forKey: "\(Constants.ExpenseFieldFromCameraKeyPrefix)\(value)")
        }
        
        // save new values
        for (key, value) in selectedTexts {
            defaults.set(value, forKey: "\(Constants.ExpenseFieldFromCameraKeyPrefix)\(key)")
        }

        selectedTexts.removeAll()
        currentFieldType = .amount
        updateValuePreviewUI()
        
        coordinator?.goToNewExpense(image: nil)
    }
    
    @IBAction @objc func switchModeTapped(_ sender: UIButton) {
        isValueScanningModeSelected = !isValueScanningModeSelected
        updateModeUI()
        updateCameraMode()
    }
    
    private func initStyles() {
        valuePreviewView.backgroundColor = UIColor.white
        valuePreviewView.layer.cornerRadius = 8
        
        // Match size of Cancel button in UIImagePickerController
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
        scanValueLabel.text = nil
        
        updateModeUI()
    }
    
    private func updateModeUI() {
        let iconName = isValueScanningModeSelected ? "doc.text.viewfinder" : "viewfinder"
        switchModeButton.setImage(UIImage(systemName: iconName, withConfiguration: switchModeButtonConfig), for: .normal)
    }
    
    private func updateCameraMode() {
        if isValueScanningModeSelected {
            
            if let imagePickerController = imagePickerController {
                isImagePickerDismissing = true
                imagePickerController.dismiss(animated: false) {
                    self.isImagePickerDismissing = false
                    self.imagePickerController = nil
                    self.cameraService.startCamera()
                }
            } else {
                cameraService.startCamera()
            }
        } else {
            cameraService.stopCamera()
            imagePickerController = ImagePickerHelper.openImagePicker(viewController: self, delegate: self, sourceType: .camera, animate: false, overlayView: initCameraPickerOverlay())
            imagePickerController?.cameraFlashMode = .auto
        }
    }
    
    private func initCameraPickerOverlay() -> UIView {
        let topBarHeight: CGFloat = 41
        let buttonWidth: CGFloat = 44
        
        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: topBarHeight))
        overlayView.backgroundColor = .black
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: topBarHeight))
        title.textAlignment = .center
        title.text = "Take a photo"
        title.textColor = .white
        overlayView.addSubview(title)
        
        let modeSwitchButton = UIButton(type: .custom)
        modeSwitchButton.frame = CGRect(x: view.bounds.width - buttonWidth, y: 0, width: buttonWidth, height: topBarHeight)
        modeSwitchButton.tintColor = .white
        modeSwitchButton.setImage(UIImage(systemName: "viewfinder", withConfiguration: switchModeButtonConfig), for: .normal)
        modeSwitchButton.addTarget(self, action: #selector(switchModeTapped(_:)), for: .touchUpInside)
        overlayView.addSubview(modeSwitchButton)
        
        flashButton = UIButton(type: .custom)
        flashButton!.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: topBarHeight)
        flashButton!.tintColor = .white
        flashButton!.setImage(UIImage(systemName: "bolt.badge.a.fill", withConfiguration: switchModeButtonConfig), for: .normal)
        flashButton!.addTarget(self, action: #selector(flashTapped(_:)), for: .touchUpInside)
        overlayView.addSubview(flashButton!)
        
        return overlayView
    }
    
    @objc private func flashTapped(_ sender: UIButton) {
        if let imagePickerController = imagePickerController {
            
            switch imagePickerController.cameraFlashMode {
                case .auto:
                    imagePickerController.cameraFlashMode = .on
                    flashButton?.setImage(UIImage(systemName: "bolt.fill", withConfiguration: switchModeButtonConfig), for: .normal)
                case .on:
                    imagePickerController.cameraFlashMode = .off
                    flashButton?.setImage(UIImage(systemName: "bolt.slash.fill", withConfiguration: switchModeButtonConfig), for: .normal)
                case .off:
                    imagePickerController.cameraFlashMode = .auto
                    flashButton?.setImage(UIImage(systemName: "bolt.badge.a.fill", withConfiguration: switchModeButtonConfig), for: .normal)
                @unknown default:
                    break
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        videoPreviewView.updateUI()

        if let navVc = navigationController,
            let tabBarVc = navVc.parent as? UITabBarController {
            valuePreviewViewBottomConstraint.constant = view.bounds.height - videoPreviewView.cameraButton.frame.minY - tabBarVc.tabBar.bounds.height + 24
        }
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        var previous = currentFieldType.rawValue - 1
        
        if previous < 0 {
            previous = FieldName.Expense.allCases.count - 1
        }
        
        currentFieldType = FieldName.Expense(rawValue: previous)!
        
        updateValuePreviewUI()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        var next = currentFieldType.rawValue + 1
        
        if next >= FieldName.Expense.allCases.count {
            next = 0
        }
        
        currentFieldType = FieldName.Expense(rawValue: next)!
        
        updateValuePreviewUI()
    }
    
    private func updateValuePreviewUI() {
        switch currentFieldType {
        case .title:
            scanTitleLabel.text = "Scan title"
        case .category:
            scanTitleLabel.text = "Scan category"
        case .amount:
            scanTitleLabel.text = "Scan amount"
        }

        scanValueLabel.text = selectedTexts[currentFieldType]
    }
    
    private func cameraButtonTapped() {
        isTextRecognitionActive = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            isImagePickerDismissing = true
            self.coordinator?.goToNewExpense(image: image)
            picker.dismiss(animated: false) {
                self.isImagePickerDismissing = false
                self.imagePickerController = nil
            }
        }        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isImagePickerDismissing = true
        self.coordinator?.returnToLastTab()
        dismiss(animated: false) {
            self.isImagePickerDismissing = false
            self.imagePickerController = nil
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if isTextRecognitionActive {
            isTextRecognitionActive = false
            
            textRecognitionService.findTextOnImageInRealtime(sampleBuffer: sampleBuffer, regionOfInterest: cameraService.regionOfInterest, orientation: cameraService.orientation) { (items) in

//                print("=== Recognized: \(items)")
                
                if let item = items.first {
                    self.documentAnalysisService.addRegion(item)
                    self.saveRecognizedValue(item: self.documentAnalysisService.imageTextElements.last)
                }                
                
                DispatchQueue.main.async {
                    self.videoPreviewView.stopAnimatingButton()
                }
            }
        }
    }
    
    private func saveRecognizedValue(item: ImageTextElement?) {
        if let item = item {
//            print("number: \(item.numberValue)")
//            print("text: \(item.text)")
            
            var stringValue = item.text
            
            if let number = item.numberValue,
                currentFieldType == .amount {
                stringValue = String(format: "%.2f", number)
            }
            
            selectedTexts[currentFieldType] = stringValue

            DispatchQueue.main.async {
                self.scanValueLabel.text = stringValue
            }
        }
    }
}
