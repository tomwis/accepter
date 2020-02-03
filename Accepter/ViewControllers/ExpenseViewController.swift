//
//  ExpenseViewController.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 17/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import AVFoundation

class ExpenseViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var titleField: ValidationField!
    @IBOutlet weak var categoryField: ValidationField!
    @IBOutlet weak var amountField: ValidationField!
    @IBOutlet weak var saveAsDraftButton: UIButton!
    @IBOutlet weak var sendToApprovalButton: UIButton!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var attachmentCountLabel: UILabel!
    @IBOutlet weak var addAttachmentButton: UIButton!
    
    weak var coordinator: Coordinator?
    let viewModel = AppDelegate.container.resolve(ExpenseViewModel.self)!
    let dialogService = AppDelegate.container.resolve(DialogService.self)!
    var expense: Expense?
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.initExpense(expense)
        
        initStyles()
        initBindings()
    }
    
    func initStyles() {
        titleField.field.placeholder = "Expense title"
        categoryField.field.placeholder = "Category"
        amountField.field.placeholder = "Amount"
        
        titleField.field.returnKeyType = .next
        categoryField.field.returnKeyType = .next
        amountField.field.returnKeyType = .done
        amountField.field.keyboardType = .numberPad
        
        titleField.field.delegate = self
        categoryField.field.delegate = self
        amountField.field.delegate = self
        
        attachmentCollectionView.register(AttachmentThumbnailCell.self, forCellWithReuseIdentifier: AttachmentThumbnailCell.reuseId)
    }
    
    func initBindings() {        
        viewModel.title.bidirectionalBind(to: titleField.field.reactive.text)
        viewModel.category.bidirectionalBind(to: categoryField.field.reactive.text)
        viewModel.amount.bidirectionalBind(to: amountField.field.reactive.text)
        viewModel.attachmentUrls.map { String($0.collection.count) }.bind(to: attachmentCountLabel.reactive.text)
        
        viewModel.attachmentThumbnails.bind(to: attachmentCollectionView, createCell: initAttachmentCell(_:_:_:))
                
        viewModel.status.map({$0 == .draft}).bind(to: titleField.field.reactive.isEnabled)
        viewModel.status.map({$0 == .draft}).bind(to: categoryField.field.reactive.isEnabled)
        viewModel.status.map({$0 == .draft}).bind(to: amountField.field.reactive.isEnabled)
        viewModel.status.map({$0 != .draft}).bind(to: saveAsDraftButton.reactive.isHidden)
        viewModel.status.map({$0 != .draft}).bind(to: sendToApprovalButton.reactive.isHidden)
        viewModel.status.map({$0 != .draft}).bind(to: addAttachmentButton.reactive.isHidden)
        
        _ = viewModel.didAdd.observeNext { (expense) in
            if let coordinator = self.coordinator as? ExpenseCoordinator {
                
                if expense.status == .draft {
                    coordinator.goToExpenseList(newExpense: expense)
                } else {
                    self.viewModel.showSendToApprovalDialog()
                }
            }
        }
        
        _ = viewModel.didModify.observeNext { (expense) in
            if let coordinator = self.coordinator as? ExpenseListCoordinator {
                coordinator.goBackToRoot()
            }
        }
        
        _ = viewModel.validationError.observeNext(with: { (error) in
            
            switch error.fieldName {
                case .title:
                    self.titleField.errorLabel.text = error.errorMessage
                case .category:
                    self.categoryField.errorLabel.text = error.errorMessage
                case .amount:
                    self.amountField.errorLabel.text = error.errorMessage
            }
        })
        
        _ = viewModel.didAddAttachment.observeNext(with: { (_) in
            let lastItemIndex = self.attachmentCollectionView.numberOfItems(inSection: 0) - 1
            self.attachmentCollectionView.scrollToItem(at: IndexPath(row: lastItemIndex, section: 0), at: .right, animated: true)
        })
    }
    
    private func initAttachmentCell(_ data: [Data], _ indexPath: IndexPath, _ collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachmentThumbnailCell.reuseId, for: indexPath)
            as? AttachmentThumbnailCell else {
            fatalError()
        }
        
        cell.imageView.image = UIImage(data: data[indexPath.row])
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onAttachmentTapped(_:))))
        
        return cell
    }
    
    @objc func onAttachmentTapped(_ recognizer: UITapGestureRecognizer) {
        if let c = coordinator as? ExpenseEditCoordinator,
            let cell = recognizer.view as? AttachmentThumbnailCell,
            let indexPath = self.attachmentCollectionView.indexPath(for: cell){
            let fileUrl = viewModel.attachmentUrls[indexPath.row]
            c.goToAttachmentPreview(viewModel: viewModel, filePath: fileUrl, indexOnList: indexPath.row)
        }
    }
    
    func clearFocus() {
        if titleField.field.canResignFirstResponder {
            titleField.field.resignFirstResponder()
        }
        
        if categoryField.field.canResignFirstResponder {
            categoryField.field.resignFirstResponder()
        }
        
        if amountField.field.canResignFirstResponder {
            amountField.field.resignFirstResponder()
        }
    }
    
    @IBAction func saveAsDraftTapped(_ sender: Any) {
        clearFocus()
        viewModel.save(sendToApproval: false)
    }
    
    @IBAction func sendToApprovalTapped(_ sender: Any) {
        clearFocus()
        viewModel.save(sendToApproval: true)
    }
    
    @IBAction func addAttachmentTapped(_ sender: Any) {
        
        let controller = UIAlertController(title: "Add an attachment", message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Take a photo", style: .default) { (_) in
            if(self.isCameraAccessAuthorized()) {
                self.openImagePicker(sourceType: .camera)
            }
        }
        let action2 = UIAlertAction(title: "From photo library", style: .default) { (_) in self.openImagePicker(sourceType: .photoLibrary) }
        controller.addAction(action1)
        controller.addAction(action2)
        
        present(controller, animated: true, completion: nil)
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = false
            present(imagePickerController, animated: true)
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
    
    private func isCameraAccessAuthorized() -> Bool {
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
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.clearValidation()
    }
}

extension ExpenseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField.field {
            textField.resignFirstResponder()
            categoryField.field.becomeFirstResponder()
        } else if textField == categoryField.field {
            textField.resignFirstResponder()
            amountField.field.becomeFirstResponder()
        }
        
        return true
    }
}

extension ExpenseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageUrl = info[.imageURL] as? URL {
            viewModel.addAttachment(url: imageUrl)
        } else if let image = info[.originalImage] as? UIImage {
            viewModel.addAttachment(data: image.jpegData(compressionQuality: 0.8))
        }
        
        picker.dismiss(animated: true)
    }
}
