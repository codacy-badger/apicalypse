import Foundation

/// An Apicalypse query to append upon requesting an entity
public struct Query<Entity> where Entity: Composable {

    /// The fields to include on the requested entities
    private var includes: [String]

    /// The fields to exclude on the requested entities
    private var excludes: [String]

    /// The filter parameters to attach to the query
    private var filters: [String]

    /// The sort parameter to attach to the query
    private var sort: String?

    /// The search parameter to attach to the query
    private var search: String?

    /// The limit parameter to attach to the query
    private var limit: Int?

    /// The offset parameter to attach to the query
    private var offset: Int?

    /// Designated initializer.
    ///
    /// Allows Query to be initialized either using `Query<Entity>()`
    /// or `Query(entity: Entity.self)` - whichever prefered.
    ///
    /// - Parameter entity: The Entity to query for
    public init(entity: Entity.Type = Entity.self) {
        includes = []
        excludes = []
        filters = []
    }
}

// MARK: - Fields

extension Array where Element == String {

    /// Include all fields in an entity request
    public static var allFields: [String] {
        return ["*"]
    }
}

extension Query {

    // MARK: Includes

    /// Example: `.include(field: \.platform)`
    public func include<Value>(field: KeyPath<Entity, Value>) throws -> Query {
        return try include(subField: field) // Does forward, but actually calls `Self.Entity`
    }

    /// Example: `.include(subField: \Logo.imageId)`
    public func include<SubEntity, Value>(subField: KeyPath<SubEntity, Value>)
        throws -> Query where SubEntity: Composable {
            return try include(field: rawCodingPath(for: Entity.codingPath(for: subField)))
    }

    /// Example: `.include(field: "platform")`
    public func include(field: String) -> Query {
        var query = self
        query.includes.append(field)
        return query
    }

    /// Example: `.include(field: [\.name, \.platform])`
    public func include(fields: [PartialKeyPath<Entity>]) throws -> Query {
        return try include(subFields: fields) // Does forward, but actually calls `Self.Entity`
    }

    /// Example: `.include(fields: [\Artwork.width, \Artwork.imageId])`
    public func include<SubEntity>(subFields: [PartialKeyPath<SubEntity>]) throws -> Query where SubEntity: Composable {
        return try include(fields: subFields.map(Entity.codingPath(for:)).map(rawCodingPath))
    }

    /// Example: `.include(fields: ["name", "platform"])`
    public func include(fields: [String]) -> Query {
        var query = self
        query.includes.append(contentsOf: fields)
        return query
    }

    // MARK: Exclude

    /// Example: `.exclude(field: \.platform)`
    public func exclude(field: PartialKeyPath<Entity>) throws -> Query {
        return try exclude(subField: field) // Does forward, but actually calls `Self.Entity`
    }

    /// Example: `.exclude(subField: \Cover.imageId)`
    public func exclude<SubEntity>(subField: PartialKeyPath<SubEntity>) throws -> Query where SubEntity: Composable {
        return try exclude(field: rawCodingPath(for: Entity.codingPath(for: subField)))
    }

    /// Example: `.exclude(field: "platform")`
    public func exclude(field: String) -> Query {
        var query = self
        query.excludes.append(field)
        return query
    }

    /// Example: `.exclude(fields: [\.name, \.platform])`
    public func exclude(fields: [PartialKeyPath<Entity>]) throws -> Query {
        return try exclude(subFields: fields) // Does forward, but actually calls `Self.Entity`
    }

    /// Example: `.exclude(subFields: [\Artwork.width, \Artwork.imageId])`
    public func exclude<SubEntity>(subFields: [PartialKeyPath<SubEntity>]) throws -> Query where SubEntity: Composable {
        return try exclude(fields: subFields.map(Entity.codingPath(for:)).map(rawCodingPath))
    }

    /// Example: `.exclude(fields: ["name", "platform"])`
    public func exclude(fields: [String]) -> Query {
        var query = self
        query.excludes.append(contentsOf: fields)
        return query
    }

    // MARK: Sort

    /// Example: `.sort(by: \.rating, order: .descending)`. Order defaults to `.descending`.
    public func sort(by field: PartialKeyPath<Entity>, order: Order = .descending) throws -> Query {
        return try sort(by: rawCodingPath(for: Entity.codingPath(for: field)), order: order)
    }

    /// Example: `.sort(by: "rating", order: .descending)`. Order defaults to `.descending`.
    public func sort(by field: String, order: Order = .descending) throws -> Query {
        var query = self
        query.sort = "\(field) \(order.rawValue)"
        return query
    }

    // MARK: Filter

    /// Example: `.where(\.platform == 48))`, `.where(\.identifier != [3, 6, 19])`
    public func `where`(_ filter: Filter<Entity>) -> Query {
        let property = rawCodingPath(for: filter.codingPath)
        let value = filter.operation.prepare(value: filter.value)
        return `where`("\(property) \(filter.operation) \(value)")
    }

    /// Example: `.where("platform = 48"))`, `.where("identifier != [3, 6, 19]")`
    public func `where`(_ filter: String) -> Query {
        var query = self
        query.filters.append(filter)
        return query
    }

    // MARK: Pagination

    /// Default limit is 10. The maximum limit is 50, for pro it is 500, and the above tiers, the maximum limit is 5000.
    ///
    /// Example: `.limit(by: 10)`
    public func limit(by value: Int) -> Query {
        var query = self
        query.limit = value
        return query
    }

    /// Example: `.offset(by: 0)`
    public func offset(by value: Int) -> Query {
        var query = self
        query.offset = value
        return query
    }

    // MARK: Helper

    /// Returns the raw coding path to given `codingPath`. For example: "game", "game.title", ...
    ///
    /// - Parameter codingPath: The `codingPath` to look up
    /// - Returns: The raw coding key path it takes to get to given `codingPath`
    private func rawCodingPath(for codingPath: [CodingKey]) -> String {
        return codingPath.map({ $0.stringValue }).joined(separator: ".")
    }
}

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

// MARK: - Build

extension Query {

    /// Generates the query string representation of `self` and returns it.
    public func build() -> String {
        var queries: String = ""
        if !includes.isEmpty { // fields name,genres;
            let values = includes.joined(separator: ",")
            queries.append("fields \(values);")
        }
        if !excludes.isEmpty { // exclude screenshots;
            let values = excludes.joined(separator: ",")
            queries.append("exclude \(values);")
        }
        if let sort = self.sort { // sort release_dates.date desc;
            queries.append("sort \(sort);")
        }
        if !filters.isEmpty { // where rating >= 80 & release_dates.date > 631152000;
            let value = filters.joined(separator: "&")
            queries.append("where \(value);")
        }
        if let limit = self.limit { // limit 33;
            let field = "limit \(String(limit));"
            queries.append(field)
        }
        if let offset = self.offset { // offset 3;
            let field = "offset \(String(offset));"
            queries.append(field)
        }
        if let search = self.search { // search "zelda";
            queries.append("search \"\(search)\";")
        }
        return queries
    }
}
