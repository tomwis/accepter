//
//  AlamofireWebRequestService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 24/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation
import Alamofire
import Accepter_Mocks

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
        sessionManager.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (response) in
                self.processResponse(response.result, completionHandler)
//                switch response.result {
//                case .success(let data):
//                    do {
//                        let result = try JSONDecoder().decode(TResponse.self, from: data)
//                        completionHandler(result)
//                    return
//                    } catch {
//                        print("Get json decoder error: \(error)")
//                    }
//                case .failure(let error):
//                    print("Get request response error: \(error)")
//                    completionHandler(nil)
//                    return
//                }
//
//            completionHandler(nil)
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
//                switch response.result {
//                case .success(let data):
//                    do {
//                        let result = try JSONDecoder().decode(TResponse.self, from: data)
//                        completionHandler(result)
//                    return
//                    } catch {
//                        print("Post json decoder error: \(error)")
//                    }
//                case .failure(let error):
//                    print("Post request response error: \(error)")
//                    completionHandler(nil)
//                    return
//                }
                
//            if let error = response.error {
//                print("Post request response error: \(error)")
//                completionHandler(nil)
//                return
//            }
//
//            if let data = response.data {
//                do {
//                    let result = try JSONDecoder().decode(TResponse.self, from: data)
//                    completionHandler(result)
//                    return
//                } catch {
//                    print("Post json decoder error: \(error)")
//                }
//            }
            
            completionHandler(nil)
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
                let result = try JSONDecoder().decode(TResponse.self, from: data)
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
}
