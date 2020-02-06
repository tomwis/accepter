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
    
    var imageService: ImageService
    
    init(imageService: ImageService) {
        self.imageService = imageService
    }
    
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
            let newImage = imageService.resizeImage(image: image, newMaxSize: maxSize, opaque: true)
            
            if let imageData = newImage?.jpegData(compressionQuality: 0.8) {
                try imageData.write(to: thumbnailUrl)

                return imageData
            }
        }
        
        return nil
    }
}
