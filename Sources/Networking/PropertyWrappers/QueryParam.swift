import Foundation

@propertyWrapper
public struct QueryParam<T> {
    public var wrappedValue: T?
    private(set) var key: String

    public init(_ key: String) {
        self.key = key
    }
}

protocol QueryParamKeyValuePair {
    var key: String { get }
    var valueAsAny: Any { get }
}

extension QueryParam: QueryParamKeyValuePair {
    var valueAsAny: Any { wrappedValue as Any }
}
