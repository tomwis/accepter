//
//  FileService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 30/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import UIKit

class FileService {
    
    func loadFile(from fileUrl: URL) throws -> Data? {
        return try Data(contentsOf: fileUrl)
    }
    
    func saveFile(at fileUrl: URL, content: Data) throws {
        try content.write(to: fileUrl)
    }
    
    func getUrlForPath(_ searchPath: FileManager.SearchPathDirectory, _ filePath: String?, _ fileName: String? = nil) throws -> URL? {
        let searchPathUrl = FileManager.default.urls(for: searchPath, in: .userDomainMask).first!
        var directoryUrl: URL
        
        if let filePath = filePath {
            directoryUrl = searchPathUrl.appendingPathComponent(filePath)
        } else {
            directoryUrl = searchPathUrl
        }
            
        var isDir = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: &isDir)
        
        if !exists || !isDir.boolValue {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        if let fileName = fileName {
            let fileUrl = directoryUrl.appendingPathComponent(fileName)
            return fileUrl
        }
        
        return directoryUrl
    }
    
    func getRandomFileNames(count: Int, fileExtension: String) -> [String] {
        return (0..<count).map { (i) in
            "\(NSUUID().uuidString).\(fileExtension)"
        }
    }
    
    func copyToAppDocuments(from sourceUrl: URL, to destinationFolder: String) throws -> URL? {
        if let destinationUrl = try getUrlForPath(.documentDirectory, destinationFolder, "\(NSUUID().uuidString).\(sourceUrl.pathExtension)") {
            try FileManager.default.copyItem(at: sourceUrl, to: destinationUrl)
            return destinationUrl
        }
        
        return nil
    }
    
    func generateThumbnail(for url: URL, at thumbnailUrl: URL, maxSize: CGSize) throws -> Data? {
                
        if let image = UIImage(contentsOfFile: url.path) {
            let newSize = getNewSizeForImage(currentSize: image.size, newMaxSize: maxSize)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let imageData = newImage?.jpegData(compressionQuality: 0.8) {
                try imageData.write(to: thumbnailUrl)

                return imageData
            }
        }
        
        return nil
    }
    
    private func getNewSizeForImage(currentSize: CGSize, newMaxSize: CGSize) -> CGSize {
        let aspectRatio = currentSize.width / currentSize.height
        var newWidth = newMaxSize.width
        var newHeight = newMaxSize.height
                    
        if aspectRatio > 1 {
            if currentSize.width < newMaxSize.width {
                newWidth = currentSize.width
            }
            
            newHeight = newWidth / aspectRatio
        } else {
            if currentSize.height < newMaxSize.height {
                newHeight = currentSize.height
            }
            
            newWidth = newHeight * aspectRatio
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return newSize
    }
}
