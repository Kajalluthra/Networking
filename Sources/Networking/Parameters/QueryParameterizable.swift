import Foundation

public protocol QueryParameterizable {
    func getParamsDictionary() -> [String: String]
}

extension QueryParameterizable {
    public func getParamsDictionary() -> [String: String] {
        let mirror = Mirror(reflecting: self)

        var dict: [String: String] = [:]

        mirror.children.forEach { child in
            if let queryParam = child.value as? QueryParamKeyValuePair {
                if let value = queryParam.valueAsAny as? String {
                    dict[queryParam.key] = value
                } else if let value = queryParam.valueAsAny as? Int {
                    dict[queryParam.key] = String(value)
                } else if let value = queryParam.valueAsAny as? Bool {
                    dict[queryParam.key] = String(value)
                }
            }
        }
        return dict
    }
}
