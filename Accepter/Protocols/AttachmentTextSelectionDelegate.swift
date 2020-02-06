//
//  AttachmentTextSelection.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 05/02/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

protocol AttachmentTextSelectionDelegate {
    func selectedText(text: String, for field: FieldName.Expense)
}
