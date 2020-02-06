//
//  TextRecognitionService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 03/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Vision

class TextRecognitionService {
    var requests = [String: VNRecognizeTextRequest]()
    
    func findTextOnImage(imageData: Data, progressHandler: @escaping (Double) -> Void, _ completionHandler: @escaping ([((CGPoint, CGPoint, CGPoint, CGPoint), String)]) -> Void) -> String {
        
        let id = NSUUID().uuidString
        
        DispatchQueue.global(qos: .background).async {
            let requestHandler = VNImageRequestHandler(data: imageData, options: [:])

            let request = VNRecognizeTextRequest { (request, error) in self.findTextOnImageCompleted(request, error, completionHandler) }
            request.recognitionLevel = .accurate
//            request.usesLanguageCorrection = true
            request.revision = VNRecognizeTextRequestRevision1
            request.progressHandler = { (request, fractionCompleted, error) in self.findTextOnImageProgress(request, fractionCompleted, error, progressHandler) }
            
            self.requests[id] = request
            
            do {
                try requestHandler.perform([request])
            } catch {
                print("findTextOnImage error: \(error)")
            }
        }
        
        return id
    }
    
    func cancelRequest(requestId: String?) {
        print("TextRecognitionService.cancelRequest: \(requestId)")
        
        if let id = requestId {
            requests[id]?.cancel()
            requests[id] = nil
        }
    }
    
    private func findTextOnImageCompleted(_ request: VNRequest, _ error: Error?, _ completionHandler: @escaping ([((CGPoint, CGPoint, CGPoint, CGPoint), String)]) -> Void) {
        guard let results = request.results as? [VNRecognizedTextObservation]
            else { return }
        
        var boundingBoxes = [((CGPoint, CGPoint, CGPoint, CGPoint), String)]()
        for visionResult in results {
            let maxCandidates = 1
            guard let candidate = visionResult.topCandidates(maxCandidates).first
                else { continue }
            
//            print("candidate: \(candidate.string)")
            
            let bounds = (visionResult.bottomLeft, visionResult.bottomRight, visionResult.topRight, visionResult.topLeft)
            boundingBoxes.append((bounds, candidate.string))
        }
        
        completionHandler(boundingBoxes)
    }
    
    private func findTextOnImageProgress(_ request: VNRequest, _ fractionCompleted: Double, _ error: Error?, _ progressHandler: @escaping (Double) -> Void) {
        if let error = error {
            print("findTextOnImageProgress error: \(error)")
        }
        
        progressHandler(fractionCompleted)
    }
}
