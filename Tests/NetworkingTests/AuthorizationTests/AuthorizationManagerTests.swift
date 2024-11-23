import XCTest
@testable import Networking
@testable import KeychainAccess

class AuthorizationManagerTests: XCTestCase {
    
    var authorizationManager: AuthorizationManager!
    var keychainMock: KeychainMock!
    
    override func setUp() {
        super.setUp()
        Networking.setup(with: ConfigMock.self)
        keychainMock = KeychainMock()
        authorizationManager = AuthorizationManager(keychain: keychainMock)
    }
    
    override func tearDown() {
        keychainMock = nil
        authorizationManager = nil
        super.tearDown()
    }
    
    private func givenAuthorizationWithSavedValues(token: String, expiration: String) {
        authorizationManager.setValues(token: token, expiration: expiration)
    }
    
    func testItReturnsLocalAuthorizationTokenWhenATokenIsSavedAndValid() async throws {
        let expiration = Calendar.current.date(byAdding: .minute, value: 60, to: Date())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        givenAuthorizationWithSavedValues(token: "mockToken", expiration: String(Int(expiration)))
        let authorizationToken = await authorizationManager.getAuthorizationToken()
        XCTAssertEqual(authorizationToken, "Bearer mockToken")
    }
    
    func testItReturnsNewTokenWhenATokenIsSavedButExpired() async throws {
        self.configureMockResponse(with: Bundle.module, jsonFilename: "AWSTokenResponse", statusCode: 200)
        authorizationManager = AuthorizationManager(keychain: keychainMock, session: urlSession)
        let expiration = Calendar.current.date(byAdding: .minute, value: -60, to: Date())?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        givenAuthorizationWithSavedValues(token: "mockToken", expiration: String(Int(expiration)))
        let authorizationToken = await authorizationManager.getAuthorizationToken()
        XCTAssertEqual(authorizationToken, "Bearer AccessToken123")
    }
    
    func testItReturnsNewTokenWhenATokenWasNotSavedBefore() async throws {
        self.configureMockResponse(with: Bundle.module, jsonFilename: "AWSTokenResponse", statusCode: 200)
        authorizationManager = AuthorizationManager(keychain: keychainMock, session: urlSession)
        let authorizationToken = await authorizationManager.getAuthorizationToken()
        XCTAssertEqual(authorizationToken, "Bearer AccessToken123")
    }
}
