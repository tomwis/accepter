//
//  UrlSessionWebRequestService.swift
//  Accepter
//
//  Created by Tomasz Wiśniewski on 24/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

class UrlSessionWebRequestService : WebRequestService {
    weak var authorizationService: AuthorizationService?
    
    func get<TResponse>(url: String, completionHandler: @escaping (TResponse?) -> Void) throws where TResponse: Decodable {
        var request = try URLRequest(url: url, method: .get)
        request.addValue("Bearer \(authorizationService?.token?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            self.processResponse(data, response, error, completionHandler)
            
//            print("Url session -> get -> response")
//            print("Data: \(data)")
//            print("Response: \(response)")
//
//            if let error = error {
//                print("Url session -> get: error: \(error)")
//                completionHandler(nil)
//                return
//            }
//
//            do {
//                if let data = data,
//                let httpResponse = response as? HTTPURLResponse,
//                    200..<300 ~= httpResponse.statusCode {
//                    let result = try JSONDecoder().decode(TResponse.self, from: data)
//                    completionHandler(result)
//                    return
//                }
//            } catch {
//                print("Error when decoding response: \(error)")
//            }
            
//                completionHandler(nil)
        }.resume()
    }
    
    func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody : Encodable, TResponse: Decodable {
        var request = try URLRequest(url: url, method: .post)
        let body = try JSONEncoder().encode(data)
        request.httpBody = body
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            self.processResponse(data, response, error, completionHandler)
//            if let error = error {
//                print("Url session -> post: error: \(error)")
//                completionHandler(nil)
//                return
//            }
//
//            do {
//                if let data = data,
//                let httpResponse = response as? HTTPURLResponse,
//                    200..<300 ~= httpResponse.statusCode {
//                    let result = try JSONDecoder().decode(TResponse.self, from: data)
//                    completionHandler(result)
//                    return
//                }
//            } catch {
//                print("Error when decoding response: \(error)")
//            }
            
//            completionHandler(nil)
        }.resume()
    }
    
    private func processResponse<TResponse>(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ completionHandler: @escaping (TResponse?) -> Void) where TResponse: Decodable {
        if let error = error {
            print("Url session -> post: error: \(error)")
            completionHandler(nil)
            return
        }
        
        do {
            if let data = data,
            let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode {
                let result = try JSONDecoder().decode(TResponse.self, from: data)
                completionHandler(result)
                return
            }
        } catch {
            print("Error when decoding response: \(error)")
        }
        
        completionHandler(nil)
    }
}
