@testable import Networking

class KeychainMock: KeychainProtocol {
    var storage = [String: String]()
    
    subscript(key: String) -> String? {
        get { storage[key] }
        set { storage[key] = newValue }
    }
}


