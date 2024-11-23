import SwiftUI

enum NetworkingConfigForPreview: NetworkingConfig {
    static var baseURL: String? { return "baseURL" }
    static var whitelabelServerURL: String { return "whitelabelServerURL"}
    static var authzIssuer: String { return "authzIssuer" }
    static var identityPoolId: String { return "identityPoolId" }
}

extension View {
    public func setupNetworking() -> some View {
        Networking.setup(with: NetworkingConfigForPreview.self)
        return self
    }
}
