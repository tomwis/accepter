//
//  AlamofireWebRequestService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 24/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireWebRequestService : WebRequestService {
    weak var authorizationService: AuthorizationService?
    
    let sessionManager: SessionManager!
    
    init(urlProtocol: URLProtocol.Type? = nil) {
        let config = URLSessionConfiguration.default
        
        if let urlProtocol = urlProtocol {
            config.protocolClasses?.insert(urlProtocol, at: 0)
        }
        
        sessionManager = SessionManager(configuration: config)
    }
    
    func get<TResponse>(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable {
        let headers = [
            "Authorization": "Bearer \(authorizationService?.token?.accessToken ?? "")"
        ]
        sessionManager.request(url, headers: headers)
            .validate(statusCode: 200..<300)
            .responseData { (response) in
                self.processResponse(response.result, completionHandler)
        }
    }
    
    func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody : Encodable, TResponse : Decodable {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let body =  try toDict(data)
        
        sessionManager.request(url, method: .post, parameters: body, headers: headers)
            .validate(statusCode: 200..<300)
            .responseData { (response) in
                self.processResponse(response.result, completionHandler)
        }
    }
    
    private func toDict<T>(_ data: T) throws -> [String: Any]? where T: (Encodable) {
        let body = try JSONEncoder().encode(data)
        let json = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        return json
    }
    
    private func processResponse<TResponse>(_ result: Result<Data>, _ completionHandler: @escaping (TResponse?) -> Void) where TResponse: Decodable {
        switch result {
        case .success(let data):
            do {
                let result = try getJsonDecoder().decode(TResponse.self, from: data)
                completionHandler(result)
            return
            } catch {
                print("Get json decoder error: \(error)")
            }
        case .failure(let error):
            print("Get request response error: \(error)")
            completionHandler(nil)
            return
        }
        
        completionHandler(nil)
    }
    
    private func getJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let dateStr = try? decoder.singleValueContainer().decode(String.self) {
                return formatter.date(from: dateStr) ?? Date()
            }
            
            return Date()
        })
        
        return decoder
    }
}
