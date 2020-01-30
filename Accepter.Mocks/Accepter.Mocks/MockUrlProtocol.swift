//
//  Accepter_Mocks.swift
//  Accepter.Mocks
//
//  Created by Tomasz Wiśniewski on 24/01/2020.
//  Copyright © 2020 Tomasz Wiśniewski. All rights reserved.
//

import Foundation

public class MockUrlProtocol: URLProtocol {
    private let bundle = Bundle.init(for: MockUrlProtocol.self)
    
    public static var apiUrls: [String: String]!
    
    public override class func canInit(with request: URLRequest) -> Bool {
        print("MockUrlProtocol -> canInit -> request: \(request)")

        return request.url!.absoluteString.hasPrefix(apiUrls["baseUrl"]!)
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        print("MockUrlProtocol -> canonicalRequest -> request: \(request)")
        return request
    }
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        print("MockUrlProtocol -> init -> request: \(request), cachedResponse: \(cachedResponse), client: \(client)")
    }
    
    public override func startLoading() {
        print("MockUrlProtocol -> startLoading: \(self.request)")
        
        let url = request.url!.absoluteString
        switch url {
            case _ where url.hasSuffix(MockUrlProtocol.apiUrls["loginUrl"]!):
                processAuthRequest()
            case _ where url.hasSuffix(MockUrlProtocol.apiUrls["userUrl"]!):
                processRequestWithAuth(file: "user_data")
            case _ where url.hasSuffix(MockUrlProtocol.apiUrls["expensesUrl"]!):
                getExpenses()
            case _ where url.hasSuffix(MockUrlProtocol.apiUrls["expensesToApproveUrl"]!):
                getExpensesToApprove()
            default:
                break
        }
    }
    
    private func processAuthRequest() {
        let jsonData = loadJsonFromFile(named: "login")
        
        if let username = getParameterFromBody(key: "username"),
            let correctEntry = getJsonEntryFromList(data: jsonData, key: "user", value: username) {
            sendResponseToClient(data: correctEntry)
        } else {
            sendUnauthorizedResponse()
        }
    }
    
    private func processRequestWithAuth(file: String) {
        let jsonData = loadJsonFromFile(named: file)
        
        if let accessToken = getAccessToken(),
            let correctEntry = getJsonEntryFromList(data: jsonData, key: "access_token", value: accessToken) {
            sendResponseToClient(data: correctEntry)
        } else {
            sendUnauthorizedResponse()
        }
    }
    
    private func getExpenses() {
        let expensesFileData = loadJsonFromFile(named: "expenses")
        let userFileData = loadJsonFromFile(named: "user_data")
        
        if let accessToken = getAccessToken() {
            if let userData = getJsonEntryFromList(data: userFileData, key: "access_token", value: accessToken),
                let userJson = try! JSONSerialization.jsonObject(with: userData, options: []) as? [String: Any],
                let login = userJson["id"] as? String,
                let correctEntries = getJsonEntriesFromList(data: expensesFileData, key: "userId", values: [login]) {
                sendResponseToClient(data: correctEntries)
            } else {
                sendResponse(withCode: 500)
            }
        } else {
            sendUnauthorizedResponse()
        }
    }
    
    private func getExpensesToApprove() {
        let expensesFileData = loadJsonFromFile(named: "expenses")
        let userFileData = loadJsonFromFile(named: "user_data")
        
        if let accessToken = getAccessToken() {
            if let userData = getJsonEntryFromList(data: userFileData, key: "access_token", value: accessToken),
                let userJson = try! JSONSerialization.jsonObject(with: userData, options: []) as? [String: Any],
                let subordinateIds = userJson["approverForUserIds"] as? [String],
                let correctEntries = getJsonEntriesFromList(data: expensesFileData, key: "userId", values: subordinateIds) {
                sendResponseToClient(data: correctEntries)
            } else {
                sendResponse(withCode: 500)
            }
        } else {
            sendUnauthorizedResponse()
        }
    }
    
    private func getAccessToken() -> String? {
        let value = request.value(forHTTPHeaderField: "Authorization")
        if let items = value?.split(separator: " "),
            items.count == 2 {
            return String(items[1])
        }
        
        return nil
    }
    
    private func getParameterFromBody(key: String) -> String? {
        if let body = getHttpBody() {
            return getUrlEncodedParamValue(data: body, key: key)
        }
        
        return nil
    }
    
    private func getHttpBody() -> Data? {
        guard let stream = request.httpBodyStream else { return nil }
        
        stream.open()
        
        let bufferSize = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()
        while stream.hasBytesAvailable {
            let length = stream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: length)
        }
        
        buffer.deallocate()
        stream.close()
    
        return data
    }
    
    private func getUrlEncodedParamValue(data: Data, key: String) -> String? {
        if let str = String(data: data, encoding: .utf8) {
            let parts = str.split(separator: "&")
            let keyvalue = parts.first { (substring) -> Bool in
                let item = substring.split(separator: "=")
                return item[0] == key
            }
            let item = keyvalue!.split(separator: "=")
            return String(item[1])
        }
        
        return nil
    }
    
    private func getJsonEntryFromList(data: Data, key: String, value: String) -> Data? {
        let list = try! JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        
        let entry = list?.first(where: { (obj) -> Bool in
            if let dict = obj as? [String: Any] {
                return (dict[key] as? String) == value
            }
            return false
        })
        
        guard let value = entry as? [String: Any] else { return nil }
        
        return try? JSONSerialization.data(withJSONObject: value["data"]!, options: [])
    }
    
    private func getJsonEntriesFromList(data: Data, key: String, values: [String]) -> Data? {
        let list = try! JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        
        let entries = list?.filter({ (obj) -> Bool in
            if let dict = obj as? [String: Any],
                let item = (dict[key] as? String) {
                return values.contains(item)
            }
            return false
        })
        
        return try? JSONSerialization.data(withJSONObject: entries!, options: [])
    }
    
    private func loadJsonFromFile(named fileName: String) -> Data {
        let path = bundle.path(forResource: fileName, ofType: "json")
        let url = URL(fileURLWithPath: path!)
        let jsonData = try! Data(contentsOf: url)
        return jsonData
    }
    
    private func sendResponseToClient(data: Data) {
        client?.urlProtocol(self, didLoad: data)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    private func sendUnauthorizedResponse() {
        sendResponse(withCode: 401)
    }
    
    private func sendResponse(withCode code: Int) {
        let response = HTTPURLResponse(url: request.url!, statusCode: code, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    public override func stopLoading() {
        print("MockUrlProtocol -> stopLoading: \(self.request)")
    }
}
