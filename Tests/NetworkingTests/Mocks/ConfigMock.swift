import Networking

public enum ConfigMock: NetworkingConfig {
    
    public static var baseURL: String? {
        return "baseURL"
    }
    
    public static var authzIssuer: String {
        return "https://asa9iuw86i.execute-api.eu-west-1.amazonaws.com/authorisation-token"
    }
    
    public static var identityPoolId: String {
        return "eu-west-1:37126d66-60da-4197-a2f5-8da778c439bf"
    }
        
    public static var whitelabelServerURL: String {
        return "whitelabelServerURL"
    }
    
}
