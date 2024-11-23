import Foundation

public struct ErrorXMLResponse: Codable, Error {
    let errorMessage: ErrorMessage?
}

public struct ErrorMessage: Codable {
    let code: String
    let value: String
}
