import Foundation
import AWSCore

public protocol NetworkingConfig {
    static var baseURL: String? { get }
    static var whitelabelServerURL: String { get }
    static var authzIssuer: String { get }
    static var identityPoolId: String { get }
}

public func setup(with config: NetworkingConfig.Type) {
    ConfigType.shared = ConfigType(config)
}

var Config: ConfigType { // swiftlint:disable:this variable_name
    if let config = ConfigType.shared {
        return config
    } else {
        fatalError("Please set the Config for \(Bundle(for: ConfigType.self))")
    }
}

final class ConfigType {
    
    static fileprivate var shared: ConfigType?
    
    let baseURL: String?
    let whitelabelServerURL: String
    let authzIssuer: String
    let identityPoolId: String
    
    fileprivate init(_ config: NetworkingConfig.Type) {
        self.baseURL = config.baseURL
        self.whitelabelServerURL = config.whitelabelServerURL
        self.authzIssuer = config.authzIssuer
        self.identityPoolId = config.identityPoolId
        setupAuthorization()
    }
    
    private func setupAuthorization() {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.EUWest1,
            identityPoolId: identityPoolId)
        let configuration = AWSServiceConfiguration(
            region: AWSRegionType.EUWest1,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
}
