//
//  AttachmentPreviewViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 31/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class TextDetectionLayer: CALayer {
    private var regions: [((CGPoint, CGPoint, CGPoint, CGPoint), String)]?
    
    init(regions: [((CGPoint, CGPoint, CGPoint, CGPoint), String)]) {
        super.init()
        
        self.regions = regions
    }
    
    override func draw(in ctx: CGContext) {
        guard let regions = regions else {
            opacity = 0.0
            return
        }
        
        ctx.setFillColor(UIColor.black.cgColor)
        let clipBounds = ctx.boundingBoxOfClipPath
        ctx.fill(clipBounds)
        
        ctx.saveGState()
        
        ctx.setFillColor(UIColor.white.cgColor)
        let width = bounds.width
        let height = bounds.height
        let path = CGMutablePath()
        
        for ((pt1, pt2, pt3, pt4), string) in regions {
            print("Rect: \(pt1), \(pt2), \(pt3), \(pt4), \(string)")
//            let topLeft = CGPoint(x: region.minX * width, y: region.minY * height)
//            let topRight = CGPoint(x: region.maxX * width, y: region.minY * height)
//            let bottomRight = CGPoint(x: region.maxX * width, y: region.maxY * height)
//            let bottomLeft = CGPoint(x: region.minX * width, y: region.maxY * height)
//            print("Rect: \(topLeft) | \(bottomRight)")
            
            let topLeft = CGPoint(x: pt4.x * width, y: (1 - pt4.y) * height)
            let topRight = CGPoint(x: pt3.x * width, y: (1 - pt3.y) * height)
            let bottomRight = CGPoint(x: pt2.x * width, y: (1 - pt2.y) * height)
            let bottomLeft = CGPoint(x: pt1.x * width, y: (1 - pt1.y) * height)
            print("Rect: \(topLeft) | \(topRight) | \(bottomRight) | \(bottomLeft)")
            
//            path.move(to: topLeft)
//            path.addLine(to: topRight)
//            path.addLine(to: bottomRight)
//            path.addLine(to: bottomLeft)
//            path.addLine(to: topLeft)

            path.move(to: CGPoint(x: pt1.x * width, y: (1 - pt1.y) * height))
            path.addLine(to: CGPoint(x: pt2.x * width, y: (1 - pt2.y) * height))
            path.addLine(to: CGPoint(x: pt3.x * width, y: (1 - pt3.y) * height))
            path.addLine(to: CGPoint(x: pt4.x * width, y: (1 - pt4.y) * height))
            path.addLine(to: CGPoint(x: pt1.x * width, y: (1 - pt1.y) * height))

//            UIGraphicsPushContext(ctx)
//            let string = NSAttributedString(string: "LOL", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
//            string.draw(at: CGPoint(x: region.minX * width, y: region.minY * height))
//            UIGraphicsPopContext()
            
            break
        }
        
        ctx.addPath(path)
        ctx.fillPath()
        
        ctx.addPath(path)
        ctx.setLineWidth(2.0)
        ctx.setStrokeColor(CGColor(srgbRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        ctx.strokePath()
        
        ctx.restoreGState()
        
        opacity = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AttachmentPreviewViewController: UIViewController, Storyboarded {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteAttachmentButton: UIBarButtonItem!
    
    var attachmentIndex: Int?
    var imageUrl: URL?
    var viewModel: ExpenseViewModel?
    
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
        
    }
    var textDetectionLayer: TextDetectionLayer?
    func selectTextOnImage() {
        if let image = imageView.image,
            let data = image.pngData() {
            TextRecognitionService().findTextOnImage(imageData: data) { (rects) in
                self.textDetectionLayer = TextDetectionLayer(regions: rects)
                self.textDetectionLayer?.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
                self.textDetectionLayer?.opacity = 0.0
                self.imageView.layer.addSublayer(self.textDetectionLayer!)
                self.textDetectionLayer?.setNeedsDisplay()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        updateImageScales()
        selectTextOnImage()
    }
    
    func updateImageScales() {
        if let image = imageView.image {
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
    
    func centerImage() {
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
}

extension AttachmentPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
        textDetectionLayer?.setNeedsDisplay()
    }
}
