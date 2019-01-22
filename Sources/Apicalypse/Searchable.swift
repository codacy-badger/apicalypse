import Foundation

/// [Search](https://apicalypse.io/syntax/#search) based on name where results are sorted by similarity.
///
/// Allows direct search on a Query, if entity conforms to this protocol.
///
/// IGDB Example:
///
///     Address: https://api-v3.igdb.com/games/
///     Body: search "zelda";
///
public protocol Searchable {}
