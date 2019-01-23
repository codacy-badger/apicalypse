import Foundation

/// `Composable` entities may be selectively requested with required properties, matching desired filters, only.
///
/// It defines the inverse path from a keyPath to the CodingKey path.
public protocol Composable {

    /// Returns the coding key of given `keyPath`
    ///
    /// - Parameter keyPath: The `keyPath` to look up
    /// - Returns: The coding keys of given `keyPath`
    static func codingPath(for keyPath: PartialKeyPath<Self>) throws -> CodingKey
}

extension Array where Element == String {

    /// Wildcard include to all fields in a `Composable`
    public static var allFields: [String] {
        return ["*"]
    }
}
