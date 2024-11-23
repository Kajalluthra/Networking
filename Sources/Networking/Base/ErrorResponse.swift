import Foundation

public struct ErrorResponse: Codable {
    let code: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case code, message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.code = try container.decode(Int.self, forKey: .code)
        } catch DecodingError.typeMismatch {
            self.code = try Int(container.decode(String.self, forKey: .code)) ?? 0
        }
        self.message = try container.decode(String.self, forKey: .message)
    }
}
