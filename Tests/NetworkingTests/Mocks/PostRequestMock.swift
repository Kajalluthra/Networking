import Foundation

struct PostRequestMock: Codable {
    
    let bodyParam1: String
    let bodyParam2: String

    init(bodyParam1: String, bodyParam2: String) {
        self.bodyParam1 = bodyParam1
        self.bodyParam2 = bodyParam2
    }
}
