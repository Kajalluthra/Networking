import Foundation
import os
import LoggerExtension

public protocol HTTPClient {
    var session: URLSession { get set }
    func sendGetRequest<T: Codable>(endpoint: GetEndpoint, responseModel: T.Type) async -> Result<SuccessResponse<T>, RequestError>
    func sendPostRequest<T: Codable>(endpoint: PostEndpoint, responseModel: T.Type) async -> Result<SuccessResponse<T>, RequestError>
    func sendPostRequest(endpoint: PostEndpoint) async -> Result<Data, RequestError>
}

extension HTTPClient {
    
    public func sendGetRequest<T: Codable>(endpoint: GetEndpoint, responseModel: T.Type) async -> Result<SuccessResponse<T>, RequestError> {
        var urlString = endpoint.baseURL + endpoint.path
        if let queryParameters = endpoint.queryParameters {
            urlString += queryParameters
        }
        Logger.network.log(level: .default, message: "Send request \(RequestMethod.get.rawValue) to \(urlString)")
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.get.rawValue
        request.allHTTPHeaderFields = await endpoint.header
        
        return await performRequest(request, endpoint: endpoint)
    }
    
    public func sendPostRequest<T: Codable>(endpoint: PostEndpoint, responseModel: T.Type) async -> Result<SuccessResponse<T>, RequestError> {
        if let request = await createPostRequest(endpoint: endpoint) {
            return await performRequest(request, endpoint: endpoint)
        } else {
            return .failure(.invalidURL)
        }
    }
    
    public func sendPostRequest(endpoint: PostEndpoint) async -> Result<Data, RequestError> {
        if let request = await createPostRequest(endpoint: endpoint) {
            return await performObjectRequest(request, endpoint: endpoint)
        } else {
            return .failure(.invalidURL)
        }
    }
    
    private func createPostRequest(endpoint: PostEndpoint) async -> URLRequest? {
        var urlString = endpoint.baseURL + endpoint.path
        if let queryParameters = endpoint.queryParameters {
            urlString += queryParameters
        }
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = RequestMethod.post.rawValue
        request.allHTTPHeaderFields = await endpoint.header
        request.httpBody = endpoint.body
        let bodyString = String(data: endpoint.body, encoding: .utf8)
        Logger.network.log(level: .default, message: "Send request \(RequestMethod.post.rawValue) to \(urlString), with body \(bodyString ?? "No body")")
        return request
    }
    
    private func performRequest<T: Codable>(_ request: URLRequest, endpoint: Endpoint, remainingAttempts: Int = 1) async -> Result<SuccessResponse<T>, RequestError> {
        do {
            let (data, response) = try await self.session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            let url = response.url?.absoluteString ?? "url: "
            let statusCode = response.statusCode
            if let dataString = String(data: data, encoding: .utf8) {
                Logger.network.log(level: .default, message: "Receive response from \(url) with code status \(statusCode) with body \(dataString)")
            } else {
                Logger.network.log(level: .default, message: "Receive response from \(url) with code status \(statusCode)")
            }
            switch response.statusCode {
            case 200...299:
                return try await attemptSuccessResponseParsing(forRequest: request, endpoint: endpoint, data: data, remainingAttempts: remainingAttempts)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch let DecodingError.keyNotFound(key, context) {
            Logger.network.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            Logger.network.error("codingPath: \(context.codingPath)")
        } catch let DecodingError.valueNotFound(value, context) {
            Logger.network.error("Value '\(value)' not found: \(context.debugDescription)")
            Logger.network.error("codingPath: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            Logger.network.error("Type '\(type)' mismatch: \(context.debugDescription)")
            Logger.network.error("codingPath: \(context.codingPath)")
        } catch let error {
            Logger.network.error("\(error.localizedDescription)")
        }
        return .failure(.unknown())
    }
    
    private func performObjectRequest(_ request: URLRequest, endpoint: Endpoint) async -> Result<Data, RequestError> {
        do {
            let (data, response) = try await self.session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            let url = response.url?.absoluteString ?? "url: "
            let statusCode = response.statusCode
            Logger.network.log(level: .default, message: "Receive response from \(url) with code status \(statusCode)")
            
            switch response.statusCode {
            case 200...299:
                return try await attemptSuccessResponseParsing(data: data)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch let DecodingError.keyNotFound(key, context) {
            Logger.network.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            Logger.network.error("codingPath: \(context.codingPath)")
        } catch let DecodingError.valueNotFound(value, context) {
            Logger.network.error("Value '\(value)' not found: \(context.debugDescription)")
            Logger.network.error("codingPath: \(context.codingPath)")
        } catch let DecodingError.typeMismatch(type, context) {
            Logger.network.error("Type '\(type)' mismatch: \(context.debugDescription)")
            Logger.network.error("codingPath: \(context.codingPath)")
        } catch let error {
            Logger.network.error("\(error.localizedDescription)")
        }
        return .failure(.unknown())
    }
    
    private func attemptSuccessResponseParsing<T: Codable>(forRequest request: URLRequest,
                                                           endpoint: Endpoint,
                                                           data: Data,
                                                           remainingAttempts: Int) async throws -> Result<SuccessResponse<T>, RequestError> {
        do {
            let decodedResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
            
            if let successResponse = decodedResponse.successResponse {
                return .success(successResponse)
            } else if let errorResponse = decodedResponse.errorResponse {
                Logger.network.error("\(errorResponse.message)")
                let errorResponse = decodedResponse.errorResponse
                if errorResponse?.code == 401 {
                    guard remainingAttempts > 0 else { return .failure(.unauthorized) }
                    var request = request
                    request.allHTTPHeaderFields = await endpoint.getHeaders(auth: true, contentType: .json)
                    return await performRequest(request, endpoint: endpoint, remainingAttempts: remainingAttempts - 1)
                } else if errorResponse?.code == 500 {
                    return .failure(.generalError(message: errorResponse?.message ?? ""))
                }
                return .failure(.unknown(code: errorResponse?.code, message: errorResponse?.message))
            }
            return .failure(.decode)
        } catch {
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return .success(SuccessResponse(data: decodedResponse, sessionId: nil, sessionDataToken: nil))
            } catch let DecodingError.keyNotFound(key, context) {
                Logger.network.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                Logger.network.error("codingPath: \(context.codingPath)")
            } catch let DecodingError.valueNotFound(value, context) {
                Logger.network.error("Value '\(value)' not found: \(context.debugDescription)")
                Logger.network.error("codingPath: \(context.codingPath)")
            } catch let DecodingError.typeMismatch(type, context) {
                Logger.network.error("Type '\(type)' mismatch: \(context.debugDescription)")
                Logger.network.error("codingPath: \(context.codingPath)")
            } catch let error {
                Logger.network.error("\(error.localizedDescription)")
            }
            return .failure(.decode)
        }
    }
    
    private func attemptSuccessResponseParsing(data: Data) async throws -> Result<Data, RequestError> {
        do {
            let decodedResponse = try JSONDecoder().decode(BaseResponse<Data>.self, from: data)
            
            if let errorResponse = decodedResponse.errorResponse {
                Logger.network.error("\(errorResponse.message)")
                let errorResponse = decodedResponse.errorResponse
                if errorResponse?.code == 401 {
                    return .failure(.unauthorized)
                } else if errorResponse?.code == 500 {
                    return .failure(.generalError(message: errorResponse?.message ?? ""))
                }
                return .failure(.unknown(code: errorResponse?.code, message: errorResponse?.message))
            }
            return .failure(.decode)
        } catch {
            return .success(data)
        }
    }
}
