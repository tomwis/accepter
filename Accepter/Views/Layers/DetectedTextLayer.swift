//
//  TextDetectionLayer.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 04/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class DetectedTextLayer: CALayer {
    private var numberElements = [(ImageTextElement, CGPath)]()
    private var textElements = [(ImageTextElement, CGPath)]()

    private var documentAnalysisService: DocumentAnalysisService?
    
    var currentTextSelectionType: FieldName.Expense?
    
    init(documentAnalysisService: DocumentAnalysisService) {
        super.init()
        
        self.documentAnalysisService = documentAnalysisService
    }
    
    override init(layer: Any) {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func draw(in ctx: CGContext) {
        guard let documentAnalysisService = documentAnalysisService else {
            opacity = 0.0
            return
        }
        
        ctx.setFillColor(UIColor.black.cgColor)
        let clipBounds = ctx.boundingBoxOfClipPath
        ctx.fill(clipBounds)
        
        ctx.saveGState()
        
        ctx.setFillColor(UIColor.white.cgColor)
        
        for element in documentAnalysisService.imageTextElements {
                        
            let path = CGMutablePath()
            path.move(to: element.bottomLeft)
            path.addLine(to: element.bottomRight)
            path.addLine(to: element.topRight)
            path.addLine(to: element.topLeft)
            path.addLine(to: element.bottomLeft)
            
            if element.numberValue != nil {
                numberElements.append((element, path))
            } else {
                textElements.append((element, path))
            }
        }
        
        switch currentTextSelectionType {
            case .amount:
                selectNumbers(context: ctx)
            default:
                selectTexts(context: ctx)
        }
        
        ctx.restoreGState()
        
        opacity = 0.5
    }
    
    func selectNumbers(context ctx: CGContext) {
        for (element, path) in numberElements {

            var fillColor = CGColor(srgbRed: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
            
            if let maxValueInLastLine = documentAnalysisService?.getPotentialMaxValueItem(),
                element === maxValueInLastLine {
                fillColor = CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
            }
            
            ctx.setFillColor(fillColor)
            ctx.addPath(path)
            ctx.fillPath()
            
            ctx.addPath(path)
            ctx.setLineWidth(2.0)
            ctx.setStrokeColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            ctx.strokePath()
        }
    }
    
    func selectTexts(context ctx: CGContext) {
        for (_, path) in textElements {

            let fillColor = CGColor(srgbRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
            ctx.setFillColor(fillColor)
            ctx.addPath(path)
            ctx.fillPath()
            
            ctx.addPath(path)
            ctx.setLineWidth(2.0)
            ctx.setStrokeColor(CGColor(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            ctx.strokePath()
        }
    }
}
