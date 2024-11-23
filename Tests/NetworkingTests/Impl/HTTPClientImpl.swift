import Foundation
import Networking

class HTTPClientImpl: HTTPClient {
    var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
}
