import Foundation

/// [Filters](https://apicalypse.io/syntax/#where)
///
/// Filters are used to sift through results to get what you want. 
/// You can exclude and include results based on their properties.
/// For example you could remove all Games where the `rating` was below 80
///
///     (`Filter<Game>(field: \.rating, comparison: .greaterThan, value: 80)`).
///
/// Most of the filter have a short inline operator version. Therefore, above rating example may instead be used as
///
///     `\.rating > 80`.
///
/// Filters can be used on any `Composable` entity.
public struct Filter: CustomStringConvertible {

    /// The entity property that should match `value`
    private let property: String

    /// The operator to test `property` against value, e.g. "=", "!=", ">", ...
    private let `operator`: Operator

    /// The value to match against `property`
    private let value: String

    /// A textual representation of this instance.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(describing:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `description` property for types that conform to
    /// `CustomStringConvertible`:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String {
        let value = self.operator.prepare(value: self.value)
        return "\(property) \(`operator`.operation) \(value)"
    }

    // MARK: Initializers

    /// Creates a new instance of `Self`, by evaluating given properties as filter.
    ///
    /// - Parameters:
    ///   - property: The entity property that should match `value`
    ///   - operator: The operator to test `property` against value, e.g. "=", "!=", ">", ...
    ///   - value: The value to match against `property`
    fileprivate init(property: String, operator: Operator, value: String?) {
        self.property = property
        self.operator = `operator`
        self.value = value ?? "null"
    }

    /// Creates a new instance of `Self`, by evaluating given properties as filter.
    ///
    /// - Parameters:
    ///   - property: The entity property that should match `value`
    ///   - operator: The operator to test `property` against value, e.g. "=", "!=", ">", ...
    ///   - value: The value to match against `property`
    public init(property: CodingKey, operator: Operator, value: String?) {
        self.init(property: property.stringValue, operator: `operator`, value: value)
    }

    /// <# Description #>
    public init<Entity, Value>(field keyPath: KeyPath<Entity, Value>, operator: Operator, value: Value)
        throws where Entity: Composable {
            try self.init(
                property: Entity.codingPath(for: keyPath),
                operator: `operator`,
                value: String(describing: value))
    }

    /// <# Description #>
    public init<Entity, Value>(field keyPath: KeyPath<Entity, Value?>, operator: Operator, value: Value?)
        throws where Entity: Composable {
            try self.init(
                property: Entity.codingPath(for: keyPath),
                operator: `operator`,
                value: value.map(String.init(describing:)))
    }

    /// <# Description #>
    public init<Entity, Value>(field keyPath: KeyPath<Entity, Value>, operator: Operator, values: Value)
        throws where Entity: Composable, Value: Collection {
            try self.init(
                property: Entity.codingPath(for: keyPath),
                operator: `operator`,
                value: values.map(String.init(describing:)).joined(separator: ","))
    }

    /// <# Description #>
    public init<Entity, Value>(field keyPath: KeyPath<Entity, Value?>, operator: Operator, values: Value?)
        throws where Entity: Composable, Value: Collection {
            try self.init(
                property: Entity.codingPath(for: keyPath),
                operator: `operator`,
                value: values?.map(String.init(describing:)).joined(separator: ","))
    }
}

// MARK: - Combinations

/// Joins `lhs` filter with `rhs` filter by creating a new filter where both given requirements must match
public func && (lhs: Filter, rhs: Filter) -> Filter {
    return Filter(property: String(describing: lhs), operator: JoiningOperator.and, value: String(describing: rhs))
}

/// Joins `lhs` filter with `rhs` filter by creating a new filter where either one of given requirements must match
public func || (lhs: Filter, rhs: Filter) -> Filter {
    return Filter(property: String(describing: lhs), operator: JoiningOperator.or, value: String(describing: rhs))
}

// MARK: - Global Filter

/// = Equal: Exact match equal. Examples: `try \.identifier == 4`, `try \.parentGame == nil`
public func == <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value) throws -> Filter where Entity: Composable {
    return try Filter(field: lhs, operator: EquatableOperator.equal, value: rhs)
}

/// != Not Equal: Exact match equal. Examples: `try \.identifier != 4`, `try \.parentGame != nil`
public func != <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value) throws -> Filter where Entity: Composable {
    return try Filter(field: lhs, operator: EquatableOperator.notEqual, value: rhs)
}

// MARK: - Numeric Filter

/// > Greater than (works only on numbers). Examples: `try \.rating > 79.9`,
public func > <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, operator: ComparisonOperator.greaterThan, value: rhs)
}

/// >= Greater than or equal to (works only on numbers). Examples: `try \.rating >= 80.0`,
public func >= <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, operator: ComparisonOperator.greaterThanOrEqual, value: rhs)
}

/// < Less than (works only on numbers). Examples: `try \.rating < 79.9`,
public func < <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, operator: ComparisonOperator.lessThan, value: rhs)
}

/// <= Less than or equal to (works only on numbers). Examples: `try \.rating <= 80.0`,
public func <= <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, operator: ComparisonOperator.lessThanOrEqual, value: rhs)
}

// MARK: - Collection Filter

/// [] contains all of these values. Examples: `try \.identifier == [3, 4, 5]`,
public func == <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Collection {
        return try Filter(field: lhs, operator: CollectionOperator.containsAll, values: rhs)
}

/// {} contains all of these values exclusively. Examples: `try \.platforms === [3, 4, 5]`,
public func === <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Collection {
        return try Filter(field: lhs, operator: CollectionOperator.containsExclusively, values: rhs)
}

/// () contains at least one of these values. Examples: `try \.identifier ~= [3, 4, 5]`,
public func ~= <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Collection {
        return try Filter(field: lhs, operator: CollectionOperator.containsAtLeastOne, values: rhs)
}

/// // ![] or !() does not contain any of these values. Examples: `try \.identifier != [3, 4, 5]`,
public func != <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter where Entity: Composable, Value: Collection {
        return try Filter(field: lhs, operator: CollectionOperator.containsNone, values: rhs)
}

// MARK: - String Filter

prefix operator * /// *string
postfix operator * /// string*
// A combination of both, prefix and postfix operator, result in *string*

prefix func * (_ value: String) -> String { return "*" + value }
postfix func * (_ value: String) -> String { return value + "*" }

/// = "Your input string" - Case sensitive match
public func == <Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter where Entity: Composable {
    return try Filter(field: lhs, operator: StringComparisonMode.caseSensitive, value: rhs)
}

/// ~ "Your input string" - Case insensitive match
public func ~= <Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter where Entity: Composable {
    return try Filter(field: lhs, operator: StringComparisonMode.caseInsensitive, value: rhs)
}
