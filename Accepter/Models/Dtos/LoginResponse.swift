//
//  LoginResponse.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 27/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

struct LoginResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Double
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
