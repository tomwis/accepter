//
//  TextRecognitionService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 03/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class TextRecognitionService {
    var requests = [String: VNRecognizeTextRequest]()
    
    func findTextOnImage(imageData: Data, progressHandler: @escaping (Double) -> Void, _ completionHandler: @escaping ([(CGRect, String)]) -> Void) -> String {
        
        let id = NSUUID().uuidString
        
        DispatchQueue.global(qos: .background).async {
            let requestHandler = VNImageRequestHandler(data: imageData, options: [:])

            let request = VNRecognizeTextRequest { (request, error) in self.findTextOnImageCompleted(request, error, completionHandler) }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
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
    
    private func findTextOnImageCompleted(_ request: VNRequest, _ error: Error?, _ completionHandler: @escaping ([(CGRect, String)]) -> Void) {
        guard let results = request.results as? [VNRecognizedTextObservation]
            else { return }
        
        var boundingBoxes = [(CGRect, String)]()
        for visionResult in results {
            let maxCandidates = 1
            guard let candidate = visionResult.topCandidates(maxCandidates).first else {
                continue
            }
            
            let bounds = CGRect(topLeft: visionResult.topLeft, topRight: visionResult.topRight, bottomLeft: visionResult.bottomLeft, bottomRight: visionResult.bottomRight)
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

    func findTextOnImageFromCamera(sampleBuffer: CMSampleBuffer, regionOfInterest: CGRect?, orientation: CGImagePropertyOrientation, _ completionHandler: @escaping ([(CGRect, String)]) -> Void) {
                
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {

            let request = VNRecognizeTextRequest { (request, error) in self.findTextOnImageFromCameraCompleted(request, error, completionHandler) }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.revision = VNRecognizeTextRequestRevision1
            
            if let regionOfInterest = regionOfInterest {
                request.regionOfInterest = regionOfInterest
            }
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print("findTextOnImageInRealtime error: \(error)")
            }
        }
    }
        
    private func findTextOnImageFromCameraCompleted(_ request: VNRequest, _ error: Error?, _ completionHandler: @escaping ([(CGRect, String)]) -> Void) {
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        var boundingBoxes = [(CGRect, String)]()
        
        // In real time detection we need only one result, so we can ignore the rest
        if let visionResult = results.first,
            let candidate = visionResult.topCandidates(1).first {
            let bounds = CGRect(topLeft: visionResult.topLeft, topRight: visionResult.topRight, bottomLeft: visionResult.bottomLeft, bottomRight: visionResult.bottomRight)
            boundingBoxes.append((bounds, candidate.string))
        }
        
        completionHandler(boundingBoxes)
    }
}
