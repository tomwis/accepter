//
//  ExpenseViewModel.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 20/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond
import RealmSwift

class ExpenseViewModel {
    let localStorageService: LocalStorageService
    let dialogService: DialogService
    let authorizationService: AuthorizationService
    let fileService: FileService
    
    let title = Observable<String?>("")
    let category = Observable<String?>("")
    let amount = Observable<String?>("")
    let status = Observable<Expense.Status>(.draft)
    let attachmentThumbnails = MutableObservableArray<Data>([])
    var attachmentUrls = MutableObservableArray<URL>([])
    var attachmentThumbnailUrls = [URL]()
    
    let didAdd = PassthroughSubject<Expense, Never>()
    let didModify = PassthroughSubject<Expense, Never>()
    let didAddAttachment = PassthroughSubject<Void, Never>()
    let validationError = PassthroughSubject<(fieldName: ValidationFieldName.Expense, errorMessage: String?), Never>()
    
    var expenseToModify: Expense?
    
    init(localStorageService: LocalStorageService, dialogService: DialogService, authorizationService: AuthorizationService,
         fileService: FileService) {
        self.localStorageService = localStorageService
        self.dialogService = dialogService
        self.authorizationService = authorizationService
        self.fileService = fileService
                
        initValidationObservers()
    }
    
    func initExpense(_ expense: Expense?) {
        expenseToModify = expense

        clearTmpAttachmentsFolder()
        
        if let expense = expense {
            title.value = expense.title
            category.value = expense.category
            amount.value = String(expense.amount)
            status.value = expense.status
            
            do {
                try loadAttachments(fileNames: Array(expense.attachments), atMax: 3)
            } catch {
                dialogService.showError(message: "Couldn't load one or more attachments")
            }
        }
    }
    
    private func initValidationObservers() {
        _ = title.observeNext { (text) in
            _ = self.validationIsEmpty(text: text, fieldName: .title)
        }
        
        _ = category.observeNext { (text) in
            _ = self.validationIsEmpty(text: text, fieldName: .category)
        }
        
        _ = amount.observeNext { (text) in
            _ = self.validationIsEmpty(text: text, fieldName: .amount)
        }
    }
    
    private func validationIsEmpty(text: String?, fieldName: ValidationFieldName.Expense) -> Bool {
        let msg = self.isNilOrEmpty(text: text) ? "Field cannot be empty" : nil
        self.validationError.send((fieldName: fieldName, errorMessage: msg))
        return msg != nil
    }
    
    private func isNilOrEmpty(text: String?) -> Bool {
        return text?.isEmpty ?? true
    }
    
    func save(sendToApproval: Bool) {
        guard !self.validationIsEmpty(text: title.value, fieldName: .title),
        !self.validationIsEmpty(text: category.value, fieldName: .category),
        !self.validationIsEmpty(text: amount.value, fieldName: .amount) else { return }
                
        guard let amountParsed = Double(amount.value!) else { return }
        let status: Expense.Status = sendToApproval ? .waitingForApproval : .draft
        
        do {
            let names = try saveAttachments()
            
            if let expenseToModify = expenseToModify {
                try updateExpense(expenseToModify: expenseToModify,
                                  title: title.value!,
                                  category: category.value!,
                                  amount: amountParsed,
                                  status: status,
                                  attachmentNames: names)
            } else {
                try addNewExpense(title: title.value!,
                                  category: category.value!,
                                  amount: amountParsed,
                                  status: status,
                                  attachmentNames: names)
            }

            clearFields()
        }
        catch {
            print("Couldn't add new expense, error: \(error)")
            dialogService.showError(message: "Couldn't save expense")
        }
    }
    
    private func clearTmpAttachmentsFolder() {
        if let directoryUrl = try? fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsTemporaryFolderName) {
            try? FileManager.default.removeItem(at: directoryUrl)
        }
    }
    
    private func loadAttachments(fileNames: [String], atMax: Int) throws {
        for fileName in fileNames {
            if let thumbnailUrl = try fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsThumbnailsFolderName, fileName),
                let fullSizeFileUrl = try fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsFolderName, fileName) {
                
                if let content = try? fileService.loadFile(from: thumbnailUrl) {
                    attachmentThumbnails.append(content)
                } else if let thumbnail = try fileService.generateThumbnail(for: fullSizeFileUrl, at: thumbnailUrl, maxSize: CGSize(width: 200, height: 200)) {
                    attachmentThumbnails.append(thumbnail)
                }
                
                attachmentUrls.append(fullSizeFileUrl)
                attachmentThumbnailUrls.append(thumbnailUrl)
            }
        }
    }
    
    private func saveAttachments() throws -> [String] {
        var names: [String] = []
        
        for attachmentTmpUrl in attachmentUrls.collection {
            if let finalUrl = try fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsFolderName, attachmentTmpUrl.lastPathComponent) {
                
                if attachmentTmpUrl.absoluteString != finalUrl.absoluteString {
                    try FileManager.default.copyItem(at: attachmentTmpUrl, to: finalUrl)
                }
                
                names.append(finalUrl.lastPathComponent)
            }
        }
        
        return names
    }
    
    func addAttachment(url imageUrl: URL) {
        do {
            if let fullAttachmentTmpUrl = try fileService.copyToAppDocuments(from: imageUrl, to: Constants.AttachmentsTemporaryFolderName),
            let thumbnailUrl = try fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsThumbnailsFolderName, fullAttachmentTmpUrl.lastPathComponent),
            let thumbnailData = try fileService.generateThumbnail(for: fullAttachmentTmpUrl, at: thumbnailUrl, maxSize: CGSize(width: 200, height: 200)) {
                
                attachmentThumbnailUrls.append(thumbnailUrl)
                attachmentUrls.append(fullAttachmentTmpUrl)
                attachmentThumbnails.append(thumbnailData)
                didAddAttachment.send()
            }
            
        } catch {
            print("Error when adding attachment: \(error)")
        }
    }
    
    func addAttachment(data: Data?) {
        guard let data = data else { return }
        
        do {
            if let url = try fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsTemporaryFolderName, "\(NSUUID().uuidString).jpeg") {
                try fileService.saveFile(at: url, content: data)
                addAttachment(url: url)
            }
        } catch {
            print("Error when saving attachment from camera: \(error)")
            dialogService.showError(message: "Couldn't add attachment")
        }
    }
    
    func deleteAttachment(at index: Int) {
        if index >= 0 && attachmentThumbnails.count > index && attachmentThumbnails.count == attachmentUrls.count &&
            attachmentThumbnails.count == attachmentThumbnailUrls.count {
            
            attachmentThumbnails.remove(at: index)
            let thumbnailUrl = attachmentThumbnailUrls.remove(at: index)
            let url = attachmentUrls.remove(at: index)
            
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: thumbnailUrl)
                        
            if let attachmentUrl = try? fileService.getUrlForPath(.documentDirectory, Constants.AttachmentsFolderName, url.lastPathComponent) {
                try? FileManager.default.removeItem(at: attachmentUrl)
            }
        }
    }
    
    private func addNewExpense(title: String, category: String, amount: Double, status: Expense.Status, attachmentNames: [String]) throws {
        let expense = Expense(title: title, category: category, amount: amount, status: status)
        expense.userId = try localStorageService.getCurrentUser()?.id
        expense.showInNotifications = status == .waitingForApproval
        expense.attachments.append(objectsIn: attachmentNames)
        
        try self.localStorageService.addExpense(expense)
        
        self.didAdd.send(expense)
    }
    
    private func updateExpense(expenseToModify: Expense, title: String, category: String, amount: Double, status: Expense.Status,
                               attachmentNames: [String]) throws {
        try localStorageService.updateExpense({
            expenseToModify.title = title
            expenseToModify.category = category
            expenseToModify.amount = amount
            expenseToModify.status = status
            expenseToModify.showInNotifications = false
            expenseToModify.attachments.removeAll()
            expenseToModify.attachments.append(objectsIn: attachmentNames)
        })
        
        didModify.send(expenseToModify)
    }
    
    func clearFields() {
        title.value = nil
        category.value = nil
        amount.value = nil
        attachmentThumbnails.removeAll()
        attachmentUrls.removeAll()
        attachmentThumbnailUrls.removeAll()
        
        clearValidation()
    }
    
    func clearValidation() {
        validationError.send((fieldName: .title, errorMessage: nil))
        validationError.send((fieldName: .category, errorMessage: nil))
        validationError.send((fieldName: .amount, errorMessage: nil))
    }
    
    func showSendToApprovalDialog() {
        dialogService.show(title: nil, body: "Expense was sent to approval", displayTimeInSeconds: 5)
    }
}
