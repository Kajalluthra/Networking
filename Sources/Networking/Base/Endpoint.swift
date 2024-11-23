import Foundation
import os
import LoggerExtension
import KeychainAccess

public enum ContentType: String {
    case json = "application/json;charset=utf-8"
}

public protocol Endpoint {
    func getHeaders(auth: Bool, contentType: ContentType) async -> [String: String]
}

extension Endpoint {
    
    public func getHeaders(auth: Bool, contentType: ContentType) async -> [String: String] {
        
        var headers: [String: String] = [:]
        headers["Content-Type"] = contentType.rawValue
        
        guard auth else { return headers }
        let authorizationManager = AuthorizationManager()
        if let authorizationToken = await authorizationManager.getAuthorizationToken() {
            headers["Authorization"] = authorizationToken
        }
        return headers
    }
}
