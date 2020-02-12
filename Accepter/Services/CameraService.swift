//
//  CameraService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 07/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import AVFoundation

class CameraService: NSObject {
    private let dialogService: DialogService
    
    private let captureSessionQueue = DispatchQueue(label: "com.example.accepter.CaptureSessionQueue")
    private let videoDataOutputQueue = DispatchQueue(label: "com.example.accepter.VideoDataOutputQueue")
    
    private var captureSession: AVCaptureSession!
    private var captureDevice: AVCaptureDevice?
    private var videoDataOutput: AVCaptureVideoDataOutput!
    var regionOfInterest: CGRect?
    var orientation = CGImagePropertyOrientation.right
    
    let textRecognitionService = TextRecognitionService()
    
    init(dialogService: DialogService) {
        self.dialogService = dialogService
    }
    
    func isCameraAccessAuthorized() -> Bool {
        let cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraPermission {
        case .notDetermined:
            requestPermission()
            return false
        case .authorized:
            return true
        case .restricted, .denied:
            dialogService.show(title: "Camera access", body: "Access to camera was denied. Open settings to allow camera access.", buttonTitle: "Settings", buttonHandler: openSettings, displayTimeInSeconds: 10)
            return false
        default:
            return false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (accessGranted) in
            if accessGranted {
            }
        }
    }
    
    func setupCamera(_ videoPreviewView: VideoPreviewView, delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Could not create capture device.")
            return
        }
        
        self.captureDevice = captureDevice
        
        if captureSession != nil && captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        captureSession = AVCaptureSession()
        videoPreviewView.session = captureSession
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Could not create device input.")
            return
        }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(delegate, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        } else {
            print("Could not add VDO output")
            return
        }
        
        calculateRegionOfInterest()
        videoPreviewView.regionOfInterest = regionOfInterest
    }
    
    private func configCamera() {
        guard let captureDevice = captureDevice else { return }
        
        // Set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
        }
    }
    
    func startCamera() {
        guard captureSession != nil else { return }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        configCamera()
        
        captureSessionQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    func stopCamera() {
        guard captureSession != nil else { return }
        
        captureSessionQueue.sync {
            self.captureSession.stopRunning()
        }        
    }
    
    func calculateRegionOfInterest() {
        let widthRatio: CGFloat = 0.8
        let heightRatio: CGFloat = 0.15
        let fromTopRatio: CGFloat = 0.3
        let y: CGFloat = 1 - fromTopRatio - heightRatio / 2.0
        
        let size = CGSize(width: widthRatio, height: heightRatio)
        regionOfInterest = CGRect(x: (1 - size.width) / 2, y: y, width: size.width, height: size.height)
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}
