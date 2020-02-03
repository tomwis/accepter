//
//  AttachmentPreviewViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 31/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Bond

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
    
    override func viewDidLayoutSubviews() {
        updateImageScales()
    }
    
    func updateImageScales() {
        if let image = imageView.image {
            var minScale: CGFloat = 1.0
            var maxScale: CGFloat
            
            if image.size.width > image.size.height {
                if image.size.width > scrollView.bounds.width {
                    minScale = scrollView.bounds.width / image.size.width
                }
                maxScale = image.size.height > scrollView.bounds.height ? 1.0 : 2.0
            } else {
                if image.size.height > scrollView.bounds.height {
                    minScale = scrollView.bounds.height / image.size.height
                }
                maxScale = image.size.width > scrollView.bounds.width ? 1.0 : 2.0
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
    }
}
