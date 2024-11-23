import XCTest
@testable import Networking
@testable import TestUtils

class HTTPClientTests: XCTestCase {
    
    override func setUp() async throws {
        Networking.setup(with: ConfigMock.self)
    }
    
    func testSendGetRequestShouldReturnExpectedObject() async throws {
        self.configureMockResponse(with: Bundle.module, jsonFilename: "ResponseMockCorrect", statusCode: 200)
        let httpClient = HTTPClientImpl(session: urlSession)
        let result = await httpClient.sendGetRequest(endpoint: GetEndpointMock(), responseModel: ResponseMock.self)

        switch result {
        case .success(let response):
            let responseMock = response.data
            XCTAssertEqual(responseMock.param1, "param1Value")
            XCTAssertEqual(responseMock.param2, false)
        case .failure(let error):
            XCTFail("Expected success, but got \(error) instead")
        }
    }

    func testSendGetRequestShouldReturnErrorFor401Response() async throws {
        self.configureMockResponse(jsonFilename: "Response401Error", statusCode: 200)
        
        let httpClient = HTTPClientImpl(session: urlSession)
        let result = await httpClient.sendGetRequest(endpoint: GetEndpointMock(), responseModel: ResponseMock.self)

        switch result {
        case .success(_):
            XCTFail("Expected failure, but got success instead")
        case .failure(let error):
            XCTAssertEqual(error, .unauthorized)
        }
    }

    func testSendPostRequestShouldReturnExpectedObject() async throws {
        self.configureMockResponse(with: Bundle.module, jsonFilename: "ResponseMockCorrect", statusCode: 200)
        let httpClient = HTTPClientImpl(session: urlSession)
        let result = await httpClient.sendPostRequest(endpoint: PostEndpointMock(), responseModel: ResponseMock.self)

        switch result {
        case .success(let response):
            let responseMock = response.data
            XCTAssertEqual(responseMock.param1, "param1Value")
            XCTAssertEqual(responseMock.param2, false)
        case .failure(let error):
            XCTFail("Expected success, but got \(error) instead")
        }
    }

    func testSendPostRequestShouldReturnErrorFor401Response() async throws {
        self.configureMockResponse(jsonFilename: "Response401Error", statusCode: 200)
        
        let httpClient = HTTPClientImpl(session: urlSession)
        let result = await httpClient.sendPostRequest(endpoint: PostEndpointMock(), responseModel: ResponseMock.self)

        switch result {
        case .success(_):
            XCTFail("Expected failure, but got success instead")
        case .failure(let error):
            XCTAssertEqual(error, .unauthorized)
        }
    }
}
