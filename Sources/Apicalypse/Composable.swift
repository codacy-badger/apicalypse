import Foundation

/// `Composable` entities may be selectively requested with required properties, matching desired filters, only.
///
/// It defines the inverse path from a keyPath to the CodingKey path.
public protocol Composable {

    /// Returns the path of coding keys it takes to get to given `keyPath`
    ///
    /// - Parameter keyPath: The `keyPath` to look up
    /// - Returns: The coding keys, or path, it takes to get to given `keyPath`
    static func codingPath(for keyPath: AnyKeyPath) throws -> [CodingKey]
}
