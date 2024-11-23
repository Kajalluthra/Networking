import Foundation

protocol KeychainProtocol {
    subscript(key: String) -> String? { get set }
}
