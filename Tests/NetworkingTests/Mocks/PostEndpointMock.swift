import Foundation
import Networking

class PostEndpointMock: PostEndpoint {
    var path: String { return "path" }
    
    var header: [String : String] { return [:] }
    
    var body: Data {
        guard let data = try? JSONEncoder().encode(PostRequestMock(bodyParam1: "value1", bodyParam2: "value2")) else { return Data() }
        return data
    }
    
    var queryParameters: String? { return "" }
    
    
}
