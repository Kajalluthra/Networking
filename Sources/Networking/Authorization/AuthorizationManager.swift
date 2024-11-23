import Foundation
import os
import LoggerExtension
import KeychainAccess

extension Keychain: KeychainProtocol {}

class AuthorizationManager {
    private var keychain: KeychainProtocol
    private let tokenKey = "awsAccessToken"
    private let expirationKey = "awsAccessTokenExpiration"
    private let session: URLSession
    
    init(keychain: KeychainProtocol = Keychain(), session: URLSession = URLSession.shared) {
        self.keychain = keychain
        self.session = session
    }
    
    func getAuthorizationToken() async -> String? {
        guard let token = retrieveTokenFromKeychain() else {
            return await fetchNewToken()
        }
        return "Bearer \(token)"
    }
    
    func setValues(token: String, expiration: String) {
        keychain[tokenKey] = token
        keychain[expirationKey] = expiration
    }
    
    private func retrieveTokenFromKeychain() -> String? {
        guard let accessToken = keychain[tokenKey],
              let expirationString = keychain[expirationKey],
              let expiration = Int(expirationString),
              isTokenValid(expiration: expiration) else {
            return nil
        }
        return accessToken
    }
    
    private func isTokenValid(expiration: Int) -> Bool {
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(expiration))
        return expirationDate.compare(Date()) == .orderedDescending
    }
    
    private func fetchNewToken(retries: Int = 1) async -> String? {
        do {
            let tokenRequest = try URLRequest.awsRequest(path: Config.authzIssuer)
            let (data, response) = try await session.data(for: tokenRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return nil
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                if let dataString = String(data: data, encoding: .utf8) {
                    Logger.network.log(level: .default, message: "Receive response from api gateway with body \(dataString)")
                    let decodedResponse = try JSONDecoder().decode(ApiGatewayResponse.self, from: data)
                    let expiration = Int(Date().addingTimeInterval(TimeInterval(decodedResponse.expiresIn)).timeIntervalSince1970)
                    self.setValues(token: decodedResponse.accessToken, expiration: String(expiration))
                    return "Bearer \(decodedResponse.accessToken)"
                }
            } else {
                Logger.network.log(level: .default, message: "Unsuccessful response: \(httpResponse.statusCode)")
            }
        } catch let error {
            Logger.network.error("\(error.localizedDescription)")
        }
        
        if retries > 0 {
            return await retryFetchNewToken(retries: retries - 1)
        }
        
        return nil
    }
    
    private func retryFetchNewToken(retries: Int) async -> String? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                Task {
                    let result = await self.fetchNewToken(retries: retries)
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
