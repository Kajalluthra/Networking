import Foundation

public struct BaseResponse<Response: Codable>: Codable {
    public let apiVersion: String
    public let errorResponse: ErrorResponse?
    public let successResponse: SuccessResponse<Response>?
}
