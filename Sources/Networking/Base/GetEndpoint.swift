import Foundation
import os

public protocol GetEndpoint: Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var header: [String: String] { get async }
    var queryParameters: String? { get }
    var isBFF: Bool { get }

}

extension GetEndpoint {
    
    public var isBFF: Bool {
        return false
    }
    
    public var baseURL: String {
        if isBFF {
            return Config.whitelabelServerURL ?? ""
        }
        return Config.baseURL ?? ""
    }
}
