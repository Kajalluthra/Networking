import Foundation
import Networking

class GetEndpointMock: GetEndpoint {
    var path: String { return "path" }
    
    var header: [String : String] { return [:] }
    
    var queryParameters: String? { return "" }
    
}
