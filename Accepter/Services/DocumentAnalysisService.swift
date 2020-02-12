//
//  DocumentAnalysisService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 05/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import UIKit

class DocumentAnalysisService {
    
    var imageTextElements = [ImageTextElement]()
    var numberElements = [ImageTextElement]()
    var textElements = [ImageTextElement]()
    
    init() { }
    
    init(regions: [((CGPoint, CGPoint, CGPoint, CGPoint), String)], imageSize: CGSize) {
        
        for ((bottomLeft, bottomRight, topRight, topLeft), text) in regions {
            imageTextElements.append(ImageTextElement(topLeftPercent: topLeft, topRightPercent: topRight, bottomLeftPercent: bottomLeft, bottomRightPercent: bottomRight, imageSize: imageSize, text: text))
        }
        
        analizeElements()
    }
    
    init(imageTextElements: [ImageTextElement]) {
        self.imageTextElements = imageTextElements
        
        analizeElements()
    }
    
    func addRegion(_ region: ((CGPoint, CGPoint, CGPoint, CGPoint), String)) {
        imageTextElements.append(ImageTextElement(topLeftPercent: region.0.3, topRightPercent: region.0.2, bottomLeftPercent: region.0.0, bottomRightPercent: region.0.1, imageSize: CGSize(), text: region.1))
        
        analizeElement(imageTextElements.last)
    }
    
    func getDataForSaving() -> [ImageTextElement] {
        return imageTextElements
    }
    
    private func analizeElements() {
        for element in imageTextElements {
            analizeElement(element)
        }
    }
    
    private func analizeElement(_ element: ImageTextElement?) {
        guard let element = element else { return }
        
        if let number = textToNumber(text: element.text) {
            element.numberValue = number
            numberElements.append(element)
        } else {
            textElements.append(element)
        }
    }
    
    func getPotentialMaxValueItem() -> ImageTextElement? {
        
        // Filter out numbers that have integer part longer than 9 digits
        // Such numbers are probably some id or serial number
        // We also filter out numbers without fractional part
        // Because financial numbers on invoices/receipts usually have fractional part
        // Even if it's just .00
        var filtered = numberElements.filter { (element) -> Bool in
            let str = String(element.numberValue!)
            var integerPart = Substring(str)
            
            if str.contains(".") {
                let parts = str.split(separator: ".")
                integerPart = parts[0]
            } else if str.contains(",") {
                let parts = str.split(separator: ",")
                integerPart = parts[0]
            } else {
                return false
            }
            
            return integerPart.count <= Constants.DocumentAnalysisAmountMaxIntegerPartDigits
        }
        
        if filtered.count == 0 {
            filtered = numberElements
        }
        
        if let maxYItem = filtered.max(by: { $0.bottomLeft.y < $1.bottomLeft.y }) {
            let itemsInLastLine = filtered.filter({ $0.bottomLeft.y > maxYItem.topLeft.y })
            return itemsInLastLine.max { $0.numberValue! < $1.numberValue! }
        }
        
        return nil
    }
    
    func getPotentialMaxValue() -> Double? {
        let item = getPotentialMaxValueItem()
        return item?.numberValue
    }
    
    func getValue(for point: CGPoint) -> String? {
        if let element = imageTextElements.first(where: { (element) -> Bool in
            element.rect.expand(by: 10).contains(point)
         }) {
            
            if let number = element.numberValue {
                return String(number)
            }
            return element.text
        }
         
        return nil
    }
    
    private func textToNumber(text: String) -> Double? {
        
        // Number can only contain currency symbol(s)
        // For example: $100 or 100 USD
        // Or in extreme cases $100 USD
        // So we are looking for max 2 words
        let words = text.split(separator: " ")
        
        if words.count > 2 {
            return nil
        }
        
        let restrictedCharacters = "!@#%^&*()=_'\\|/?<>[]{}§`~;:"
        let digits = "0123456789"
        let acceptedCharacters = digits + ",."
        let digitsSet = Set(digits)
        
        // Non number words can only be currency codes
        // So non number words can have max. 3 letters
        // Also, if we find that 2 or more words are non numbers
        // Then we can return nil too, because we allow only 2 words above
        let nonNumberWords = words.filter { (substring) -> Bool in
            let commonElements = digitsSet.intersection(substring)
            return commonElements.count == 0
        }
        
        if nonNumberWords.count > 1 || nonNumberWords.filter({$0.count > 3}).count > 0 {
            return nil
        }
                
        // We want to cut out leading and trailing symbols
        // It is highly possible that text detection algorithm recognized some noise as a symbol
        // For example: table columns line separator as | sign
        let trimmedString = text.trimmingCharacters(in: CharacterSet(charactersIn: restrictedCharacters))
        
        var startIndex = -1
        var endIndex = -1
        
        // We are looking for part of string with a number
        // If we find more than one number or any of restricted characters we return nil
        for (index, character) in trimmedString.enumerated() {
            
            if restrictedCharacters.contains(character) {
                return nil
            }
            
            if acceptedCharacters.contains(character) {
                if startIndex == -1 {
                    startIndex = index
                } else if endIndex != -1 {
                    // we already found one number, so it's longer text, not just a number
                    return nil
                }
            } else if startIndex != -1 && endIndex == -1 {
                endIndex = index
            }
        }
        
        if startIndex > endIndex {
            // If number is ending together with whole string then endIndex won't be set
            // So we set it here to the end of the string
            endIndex = trimmedString.count
        }
        
        // We didn't find any number in the string
        if startIndex == -1 || endIndex == -1 {
            return nil
        }
        
        // Take the number that we found and try to parse it
        // We try it in 2 formats ('.' or ',' as decimal separator)
        let stringNumber = trimmedString.dropFirst(startIndex).prefix(endIndex - startIndex)
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        var num = formatter.number(from: String(stringNumber))
        
        if num == nil {
            formatter.decimalSeparator = ","
            formatter.groupingSeparator = "."
            num = formatter.number(from: String(stringNumber))
        }
                
        return num?.doubleValue
    }
}
