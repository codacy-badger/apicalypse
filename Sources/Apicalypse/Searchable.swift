import Foundation

/// [Search](https://apicalypse.io/syntax/#search) based on name where results are sorted by similarity.
///
/// Allows direct search on a Query, if entity conforms to this protocol.
///
/// IGDB Example:
///
///     Address: https://api-v3.igdb.com/games/
///     Body: include *; search "zelda";
///
public protocol Searchable: Composable {}

extension Query where Entity: Searchable {

    /// IGDB Examples:
    ///
    /// - Character `.search(for: "Master Chief")`
    /// - Collection: `.search(for: "Halo")`
    /// - Game: `.search(for: "Combat Evolved")`
    /// - Platform: `.search(for: "Xbox")`
    /// - Theme: `.search(for: "Survival")`
    public func search(for value: String) -> Query {
        var query = self
        query.search = value
        return query
    }
}
