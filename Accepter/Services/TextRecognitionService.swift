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
    func findTextOnImage(imageData: Data, _ completionHandler: @escaping ([((CGPoint, CGPoint, CGPoint, CGPoint), String)]) -> Void) {
        let requestHandler = VNImageRequestHandler(data: imageData, options: [:])
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let results = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            var boundingBoxes = [((CGPoint, CGPoint, CGPoint, CGPoint), String)]()
            for visionResult in results {
                let maxCandidates = 1
                guard let candidate = visionResult.topCandidates(maxCandidates).first else {
                    continue
                }
//                print("Candidate: '\(candidate.string)', rect: \(visionResult.boundingBox)")
                
                let bounds = (visionResult.bottomLeft, visionResult.bottomRight, visionResult.topRight, visionResult.topLeft)
                boundingBoxes.append((bounds, candidate.string))
            }
            
            completionHandler(boundingBoxes)
        }
        request.recognitionLevel = .accurate
        request.revision = VNRecognizeTextRequestRevision1
        
        try! requestHandler.perform([request])
    }
}
