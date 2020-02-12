//
//  VideoPreviewView.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 07/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPreviewView: UIView {
    private var regionOfInterestView: UIView?
    private var maskLayer: CAShapeLayer?
    
    var uiRotationTransform = CGAffineTransform.identity
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    var roiToGlobalTransform = CGAffineTransform.identity
    
    let cameraButtonSize: CGFloat = 66
    let cameraButtonBorder: CGFloat = 6
    let cameraButtonBorderSpacing: CGFloat = 2
    var cameraButton: UIButton!
    var cameraButtonTapped: (() -> Void)?
    var cameraButtonActivityIndicator: UIActivityIndicatorView!
    var cameraButtonFillLayer: CAShapeLayer!
    var wasCameraButtonStopped = true
    
    var regionOfInterest: CGRect? {
        didSet {
            if regionOfInterest != nil {
                updateRegionOfInterestView()
            }
        }
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createRegionOfInterestView()
        createCameraButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createRegionOfInterestView()
        createCameraButton()
    }
    
    private func createRegionOfInterestView() {
        regionOfInterestView = UIView(frame: UIScreen.main.bounds)
        regionOfInterestView?.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        regionOfInterestView?.isUserInteractionEnabled = false
        
        maskLayer = CAShapeLayer()
        maskLayer?.backgroundColor = UIColor.clear.cgColor
        maskLayer?.fillRule = .evenOdd
        regionOfInterestView?.layer.mask = maskLayer
        
        addSubview(regionOfInterestView!)
    }
    
    func updateRegionOfInterestView() {
        guard let regionOfInterest = regionOfInterest else {
            maskLayer?.path = nil
            return
        }

        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)
        uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let cutout = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: regionOfInterest.applying(roiRectTransform))
        
        let path = UIBezierPath(rect: regionOfInterestView!.frame)
        path.append(UIBezierPath(rect: cutout))
        maskLayer?.path = path.cgPath
    }

    private func createCameraButton() {
        cameraButton = UIButton(type: .custom)
        cameraButton.layer.addSublayer(getBorderPathForButton())
        cameraButtonFillLayer = getFillPathForButton()
        cameraButton.layer.addSublayer(cameraButtonFillLayer)
        
        addActivityIndicatorToButton()
        
        cameraButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.widthAnchor.constraint(equalToConstant: cameraButtonSize).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: cameraButtonSize).isActive = true
    }
    
    func updateUI() {
        updateRegionOfInterestView()
    }
    
    private func addActivityIndicatorToButton() {
        cameraButtonActivityIndicator = UIActivityIndicatorView(style: .large)
        cameraButtonActivityIndicator.color = UIColor.white
        let x = (cameraButtonSize - cameraButtonActivityIndicator.frame.width) / 2
        let y = (cameraButtonSize - cameraButtonActivityIndicator.frame.height) / 2
        cameraButtonActivityIndicator.frame = CGRect(x: x, y: y, width: cameraButtonActivityIndicator.frame.width, height: cameraButtonActivityIndicator.frame.height)
        cameraButtonActivityIndicator.hidesWhenStopped = true
        cameraButton.addSubview(cameraButtonActivityIndicator)
    }
    
    private func getBorderPathForButton() -> CAShapeLayer {
        let pathLayer = CAShapeLayer()
        // we want border to be inside the button
        let path = UIBezierPath(ovalIn: CGRect(x: cameraButtonBorder / 2, y: cameraButtonBorder / 2, width: cameraButtonSize - cameraButtonBorder, height: cameraButtonSize - cameraButtonBorder))
        pathLayer.path = path.cgPath
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.strokeColor = UIColor.white.cgColor
        pathLayer.lineWidth = cameraButtonBorder
        
        return pathLayer
    }

    private func getFillPathForButton() -> CAShapeLayer {
        let pathLayer = CAShapeLayer()
        let borderWithSpacing = cameraButtonBorder + cameraButtonBorderSpacing
        let path = UIBezierPath(ovalIn: CGRect(x: borderWithSpacing, y: borderWithSpacing, width: cameraButtonSize - borderWithSpacing * 2, height: cameraButtonSize - borderWithSpacing * 2))
        pathLayer.path = path.cgPath
        pathLayer.fillColor = UIColor.white.cgColor
        
        return pathLayer
    }

    private func getFillPathForButtonHighlighted() -> CAShapeLayer {
        let pathLayer = CAShapeLayer()
        let borderWithSpacing = cameraButtonBorder * 2
        let path = UIBezierPath(ovalIn: CGRect(x: borderWithSpacing, y: borderWithSpacing, width: cameraButtonSize - borderWithSpacing * 2, height: cameraButtonSize - borderWithSpacing * 2))
        pathLayer.path = path.cgPath
        pathLayer.fillColor = UIColor.white.cgColor
        
        return pathLayer
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        
        if wasCameraButtonStopped {
            wasCameraButtonStopped = false
            animateButton()
            cameraButtonTapped?()
        }
    }
    
    func stopAnimatingButton() {
        wasCameraButtonStopped = true
        cameraButtonActivityIndicator.stopAnimating()
        cameraButtonFillLayer.isHidden = false
    }
    
    func animateButton() {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.08
        animation.fromValue = cameraButtonFillLayer.path
        let toValue = getFillPathForButtonHighlighted().path
        animation.toValue = toValue
        animation.autoreverses = true
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        cameraButtonFillLayer.add(animation, forKey: "path")
    }
}

extension VideoPreviewView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !wasCameraButtonStopped {
            cameraButtonActivityIndicator.startAnimating()
            cameraButtonFillLayer.isHidden = true
        }
    }
}
