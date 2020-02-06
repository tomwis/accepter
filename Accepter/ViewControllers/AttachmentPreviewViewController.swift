//
//  AttachmentPreviewViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 31/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class AttachmentPreviewViewController: UIViewController, Storyboarded {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteAttachmentButton: UIBarButtonItem!
    @IBOutlet weak var analisisView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var selectTextTitleLabel: UILabel!
    @IBOutlet weak var selectedTextLabel: UILabel!
    @IBOutlet weak var textSelectionPreviewView: UIView!
    
    private var doubleTapRecognizer: UITapGestureRecognizer?
    private var currentTextSelectionType = FieldName.Expense.amount
    private var zoomScalesInitialized = false
    
    var attachmentIndex: Int?
    var imageUrl: URL?
    var viewModel: ExpenseViewModel?
    var detectedTextLayer: DetectedTextLayer?
    var documentAnalysisService: DocumentAnalysisService?
    let textRecognitionService = TextRecognitionService()
    let imageService = ImageService()
    var textSelectionDelegate: AttachmentTextSelectionDelegate?
    var textRecognitionRequestId: String?
    
    var selectedTexts = [FieldName.Expense: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        if let imageUrl = imageUrl {
            imageView.image = UIImage(contentsOfFile: imageUrl.path)
            
        }
        
        if let vm = viewModel {
            if vm.status.value != .draft {
                navigationItem.setRightBarButtonItems([], animated: false)
            }
        }
        
        selectedTextLabel.text = nil
        
        addZoomOnDoubleTap()
        findTextOnImage()
    }
    
    private func addZoomOnDoubleTap() {
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onScrollViewDoubleTap))
        doubleTapRecognizer?.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer!)
    }
    
    @objc private func onScrollViewDoubleTap(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale < scrollView.maximumZoomScale {
            
            var newScale = scrollView.zoomScale * 2
            if newScale > scrollView.maximumZoomScale {
                newScale = scrollView.maximumZoomScale
            }
            
            let center = recognizer.location(in: imageView)
            let width = scrollView.frame.width / newScale
            let height = scrollView.frame.height / newScale
            
            let rect = CGRect(x: center.x - width / 2.0, y: center.y - height / 2.0, width: width, height: height)
            scrollView.zoom(to: rect, animated: true)
        } else {
            scrollView.zoom(to: imageView.bounds, animated: true)
        }
    }
    
    private func addSelectingTextOnTap() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onScrollViewTap))
        scrollView.addGestureRecognizer(recognizer)
        
        if let doubleTapRecognizer = doubleTapRecognizer {
            recognizer.require(toFail: doubleTapRecognizer)
        }
    }
    
    @objc private func onScrollViewTap(recognizer: UITapGestureRecognizer) {
        let center = recognizer.location(in: imageView)
        
        if let value = self.documentAnalysisService?.getValue(for: center) {
            var stringValue = value
            
            if currentTextSelectionType == .amount,
                let number = Double(value) {
                stringValue = String(format: "%.2f", number)
            }
            
            selectedTexts[currentTextSelectionType] = stringValue
            selectedTextLabel.text = stringValue
            textSelectionDelegate?.selectedText(text: stringValue, for: currentTextSelectionType)
        }
    }
    
    func findTextOnImage() {
        guard !loadSavedImageData(),
            let image = self.imageView.image,
            let smallImage = imageService.resizeImage(image: image,
                                                      lowerDimensionMaxSize: Constants.ImageTextRecognitionMaxLowerDimensionSize,
                                                      opaque: true),
            let data = smallImage.pngData()
            else { return }
        
        textSelectionPreviewView.isHidden = true
        analisisView.isHidden = false
        progressView.progress = 0
        let startTime = DispatchTime.now()
        
        textRecognitionRequestId = textRecognitionService.findTextOnImage(imageData: data, progressHandler: onTextRecognitionProgress) { (regions) in
            DispatchQueue.main.async {
                self.documentAnalysisService = DocumentAnalysisService(regions: regions, imageSize: image.size)
                self.initDetectedTextLayer(layerSize: image.size)
                self.updateBottomView()
                self.addSelectingTextOnTap()
                
                let endTime = DispatchTime.now()
                let nanoInterval = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                let secondsInterval = Double(nanoInterval) / 1_000_000_000
                print("Text recognition time: \(secondsInterval) seconds")                
            }
        }
    }
    
    private func loadSavedImageData() -> Bool {
        selectedTexts[.title] = viewModel?.title.value
        selectedTexts[.category] = viewModel?.category.value
        selectedTexts[.amount] = viewModel?.amount.value
        selectedTextLabel.text = selectedTexts[currentTextSelectionType]
        
        guard let imageUrl = imageUrl,
            let image = imageView.image,
            let imageTextElements = viewModel?.loadAttachmentImageData(for: imageUrl)
            else { return false }

        documentAnalysisService = DocumentAnalysisService(imageTextElements: imageTextElements)
        initDetectedTextLayer(layerSize: image.size)
        updateBottomView()
        addSelectingTextOnTap()
        
        return true
    }
    
    private func initDetectedTextLayer(layerSize: CGSize) {
        detectedTextLayer = DetectedTextLayer(documentAnalysisService: documentAnalysisService!)
        detectedTextLayer?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: layerSize)
        detectedTextLayer?.opacity = 0.0
        detectedTextLayer?.currentTextSelectionType = currentTextSelectionType
        imageView.layer.addSublayer(detectedTextLayer!)
        detectedTextLayer?.setNeedsDisplay()
    }
    
    private func updateBottomView() {
        if selectedTextLabel.text?.isEmpty == true,
            let value = self.documentAnalysisService?.getPotentialMaxValue() {
            let stringValue = String(format: "%.2f", value)
            selectedTextLabel.text = stringValue
            selectedTexts[.amount] = stringValue
            textSelectionDelegate?.selectedText(text: stringValue, for: .amount)
        }

        textSelectionPreviewView.isHidden = false
        analisisView.isHidden = true
    }
    
    private func onTextRecognitionProgress(fractionCompleted: Double) {
        print("fractionCompleted: \(fractionCompleted)")
        DispatchQueue.main.async {
            self.progressView.progress = Float(fractionCompleted)
        }
    }
    
    override func viewDidLayoutSubviews() {
        updateImageScales()
    }
    
    private func updateImageScales() {
        if let image = imageView.image,
            !zoomScalesInitialized {
            zoomScalesInitialized = true
            var minScale: CGFloat = 1.0
            var maxScale: CGFloat
            
            if image.size.width > image.size.height {
                if image.size.width > scrollView.bounds.width {
                    minScale = scrollView.bounds.width / image.size.width
                }
                maxScale = image.size.height > scrollView.bounds.height * 2 ? 1.0 : 2.0
            } else {
                if image.size.height > scrollView.bounds.height {
                    minScale = scrollView.bounds.height / image.size.height
                }
                maxScale = image.size.width > scrollView.bounds.width * 2 ? 1.0 : 2.0
            }
            
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = maxScale
            scrollView.setZoomScale(minScale, animated: false)
            
            centerImage()
        }
    }
    
    private func centerImage() {
        if let _ = imageView.image {
            let yOffset = max(0, (scrollView.bounds.height - imageView.frame.height) / 2)
            imageViewTopConstraint.constant = yOffset
            imageViewBottomConstraint.constant = yOffset
            
            let xOffset = max(0, (scrollView.bounds.width - imageView.frame.width) / 2)
            imageViewLeadingConstraint.constant = xOffset
            imageViewTrailingConstraint.constant = xOffset
            
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        if let vm = viewModel,
            let index = attachmentIndex {
            vm.deleteAttachment(at: index)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func previousSelectionTypeTapped(_ sender: Any) {
        print("previousSelectionTypeTapped")
        var previous = currentTextSelectionType.rawValue - 1
        
        if previous < 0 {
            previous = FieldName.Expense.allCases.count - 1
        }
        
        currentTextSelectionType = FieldName.Expense(rawValue: previous)!
        
        updateTextSelectionUI()
    }
    
    @IBAction func nextSelectionTypeTapped(_ sender: Any) {
        print("nextSelectionTypeTapped")
        var next = currentTextSelectionType.rawValue + 1
        
        if next >= FieldName.Expense.allCases.count {
            next = 0
        }
        
        currentTextSelectionType = FieldName.Expense(rawValue: next)!
        
        updateTextSelectionUI()
    }
    
    private func updateTextSelectionUI() {
        switch currentTextSelectionType {
        case .title:
            selectTextTitleLabel.text = "Select title"
        case .category:
            selectTextTitleLabel.text = "Select category"
        case .amount:
            selectTextTitleLabel.text = "Select amount"
        }

        detectedTextLayer?.currentTextSelectionType = currentTextSelectionType
        detectedTextLayer?.setNeedsDisplay()
        selectedTextLabel.text = selectedTexts[currentTextSelectionType]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        textRecognitionService.cancelRequest(requestId: textRecognitionRequestId)
        
        viewModel?.saveAttachmentImageData(for: imageUrl, data: documentAnalysisService?.getDataForSaving())
    }
}

extension AttachmentPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
