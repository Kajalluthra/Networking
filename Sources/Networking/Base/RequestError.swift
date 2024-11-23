import Foundation

public enum RequestError: Error, Equatable {
    case decode
    case forbidden
    case invalidURL
    case noResponse
    case notFound
    case unauthorized
    case unexpectedStatusCode
    case notAllowedData(message: String)
    case generalError(message: String)
    case unknown(code: Int? = nil, message: String? = nil)

    public var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .forbidden:
            return "Forbidden access"
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "Session expired"
        case .notAllowedData(let message):
            return message
        default:
            return "Unknown error"
        }
    }
}
