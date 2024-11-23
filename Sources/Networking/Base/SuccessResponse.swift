import Foundation

public struct SuccessResponse<Response: Codable>: Codable {
    public let data: Response
    public let sessionId: String?
    public let sessionDataToken: String?
}
