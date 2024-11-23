import Foundation
import os

public protocol PostEndpoint: Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var header: [String: String] { get async }
    var body: Data { get }
    var queryParameters: String? { get }
}

extension PostEndpoint {
    public var baseURL: String {
        return Config.baseURL ?? ""
    }
}
