import Foundation
import AWSCore

enum SimpleAWSRequestError: Error {
    case defaultConfigurationNotFound
    case configurationInitFailed
}

extension URLRequest {

    static func awsRequest(path: String) throws -> URLRequest {

        guard let serviceConfiguration = AWSServiceManager.default()?.defaultServiceConfiguration else {
            throw SimpleAWSRequestError.defaultConfigurationNotFound
        }

        let endpoint = AWSEndpoint(region: serviceConfiguration.regionType, serviceName: "execute-api", url: URL(string: path))

        guard let configuration = AWSServiceConfiguration(region: serviceConfiguration.regionType,
                                                          endpoint: endpoint,
                                                          credentialsProvider: serviceConfiguration.credentialsProvider) else {
            throw SimpleAWSRequestError.configurationInitFailed
        }

        let signer = AWSSignatureV4Signer(credentialsProvider: configuration.credentialsProvider, endpoint: configuration.endpoint)
        let baseInterceptor = AWSNetworkingRequestInterceptor(userAgent: configuration.userAgent)

        let url = configuration.endpoint.url.appendingPathComponent("request")
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("RAILAPP", forHTTPHeaderField: "x-partner-identifier")
        baseInterceptor?.interceptRequest(request)
        signer.interceptRequest(request)

        return request as URLRequest
    }
}
