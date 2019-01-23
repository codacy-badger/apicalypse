import Foundation

/// An Apicalypse query to append upon requesting an entity
public struct Query<Entity> where Entity: Composable {

    /// The fields to include on the requested entities
    public var includes: [String]

    /// The fields to exclude on the requested entities
    public var excludes: [String]

    /// The filter parameter(s) to attach to the query
    public var filter: Filter?

    /// The sort parameter to attach to the query
    public var sort: String?

    /// The search parameter to attach to the query
    public var search: String?

    /// The limit parameter to attach to the query
    public var limit: Int?

    /// The offset parameter to attach to the query
    public var offset: Int?

    /// Designated initializer.
    ///
    /// Allows Query to be initialized either using `Query<Entity>()`
    /// or `Query(entity: Entity.self)` - whichever prefered.
    ///
    /// - Parameter entity: The Entity to query for
    public init(entity: Entity.Type = Entity.self) {
        includes = []
        excludes = []
    }
}

extension Query {

    // MARK: Includes

    /// Example: `.include(\.platform)`
    public func include<Value>(_ field: KeyPath<Entity, Value>) throws -> Query {
        return try include(contentsOf: [field])
    }

    /// Example: `.include("platform")`
    public func include(_ field: String) -> Query {
        return include(contentsOf: [field])
    }

    /// Example: `.include(contentsOf: [\.name, \.platform])`
    public func include(contentsOf fields: [PartialKeyPath<Entity>]) throws -> Query {
        return include(contentsOf: try fields.map({ try Entity.codingPath(for: $0).stringValue }))
    }

    /// Example: `.include(contentsOf: ["name", "platform"])`
    public func include(contentsOf fields: [String]) -> Query {
        var query = self
        query.includes.append(contentsOf: fields)
        return query
    }

    // MARK: Exclude

    /// Example: `.exclude(\.platform)`
    public func exclude<Value>(_ field: KeyPath<Entity, Value>) throws -> Query {
        return try exclude(contentsOf: [field])
    }

    /// Example: `.exclude("platform")`
    public func exclude(_ field: String) -> Query {
        return exclude(contentsOf: [field])
    }

    /// Example: `.exclude(contentsOf: [\.name, \.platform])`
    public func exclude(contentsOf fields: [PartialKeyPath<Entity>]) throws -> Query {
        return exclude(contentsOf: try fields.map({ try Entity.codingPath(for: $0).stringValue }))
    }

    /// Example: `.exclude(contentsOf: ["name", "platform"])`
    public func exclude(contentsOf fields: [String]) -> Query {
        var query = self
        query.excludes.append(contentsOf: fields)
        return query
    }

    // MARK: Sort

    /// Example: `.sort(by: \.rating, order: .descending)`. Order defaults to `.descending`.
    public func sort<Value>(by field: KeyPath<Entity, Value>, order: Order = .descending) throws -> Query {
        return try sort(by: Entity.codingPath(for: field).stringValue, order: order)
    }

    /// Example: `.sort(by: "rating", order: .descending)`. Order defaults to `.descending`.
    public func sort(by field: String, order: Order = .descending) throws -> Query {
        var query = self
        query.sort = "\(field) \(order.rawValue)"
        return query
    }

    // MARK: Filter

    /// Example: `.where(\.platform == 48))`, `.where(\.identifier != [3, 6, 19])` - last one wins
    public func `where`(_ filter: Filter) -> Query {
        var query = self
        query.filter = filter
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
        if let filter = self.filter { // where rating >= 80 & release_dates.date > 631152000;
            queries.append("where \(filter);")
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
