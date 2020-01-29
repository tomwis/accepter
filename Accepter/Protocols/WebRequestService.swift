//
//  WebRequestService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 24/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

protocol WebRequestService {
    var authorizationService: AuthorizationService? { get set }
    func get<TResponse>(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable
    func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody: Encodable, TResponse: Decodable
}
