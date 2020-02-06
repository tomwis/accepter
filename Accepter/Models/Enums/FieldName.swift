//
//  ValidationField.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 21/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

struct FieldName {
    enum Expense: Int, CaseIterable {
        case title
        case category
        case amount
    }
}
