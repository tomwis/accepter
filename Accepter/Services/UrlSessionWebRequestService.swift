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
        }.resume()
    }
    
    func post<TBody, TResponse>(url: String, data: TBody, completionHandler: @escaping (TResponse?) -> Void) throws where TBody : Encodable, TResponse: Decodable {
        var request = try URLRequest(url: url, method: .post)
        let body = try JSONEncoder().encode(data)
        let dict = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        if let bodyParams = dict?.reduce("", { (result, partialResult) -> String in
            return result + "\(partialResult.key)=\(partialResult.value)&"
        }) {
            request.httpBody = Data(bodyParams.utf8)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.processResponse(data, response, error, completionHandler)
            }.resume()
        }
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
                let result = try getJsonDecoder().decode(TResponse.self, from: data)
                completionHandler(result)
                return
            }
        } catch {
            print("Error when decoding response: \(error)")
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
