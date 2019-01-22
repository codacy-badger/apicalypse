import Foundation

/// [Filters](https://apicalypse.io/syntax/#where)
///
/// Filters are used to sift through results to get what you want. You can exclude and include results based on their properties.
/// For example you could remove all Games where the `rating` was below 80
///
///     (`Filter<Game>(field: \.rating, comparison: .greaterThan, value: 80)`).
///
/// Most of the filter have a short inline operator version. Therefore, above rating example may instead be used as
///
///     `\.rating > 80`.
///
/// Filters can be used on any `Composable` entity.
public struct Filter<Entity> where Entity: Composable {

    /// The coding key path to the property
    internal let codingPath: [CodingKey]

    /// The given operator, e.g. "=", "!=", ">", ... 
    internal let operation: Operator

    /// The matching value
    internal let value: String

    /// <# Description #>
    public init(field codingPath: [CodingKey], comparison: Operator, value: String?) {
        self.codingPath = codingPath
        self.operation = comparison
        self.value = value ?? "null"
    }

    /// <# Description #>
    public init(field keyPath: PartialKeyPath<Entity>, comparison: Operator, value: String?) throws {
        try self.init(field: Entity.codingPath(for: keyPath), comparison: comparison, value: value)
    }

    /// <# Description #>
    public init<Value>(field keyPath: KeyPath<Entity, Value>, comparison: Operator, value: Value?)
        throws where Value: LosslessStringConvertible {
            let field = keyPath as PartialKeyPath<Entity>
            let rhs = value.map(String.init(describing:))
            try self.init(field: field, comparison: comparison, value: rhs)
    }

    /// <# Description #>
    public init<Value>(field keyPath: KeyPath<Entity, Value>, comparison: Operator, values: [Value])
        throws where Value: LosslessStringConvertible {
            let field = keyPath as PartialKeyPath<Entity>
            let rhs = values.map(String.init(describing:)).joined(separator: ",")
            try self.init(field: field, comparison: comparison, value: rhs)
    }
}

// MARK: - Global Filter

/// = Equal: Exact match equal. Examples: `try \.identifier == 4`, `try \.parentGame == nil`
public func ==<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value?)
    throws -> Filter<Entity> where Entity: Composable, Value: LosslessStringConvertible {
        return try Filter(field: lhs, comparison: EquatableOperator.equal, value: rhs)
}

/// != Not Equal: Exact match equal. Examples: `try \.identifier != 4`, `try \.parentGame != nil`
public func !=<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value?)
    throws -> Filter<Entity> where Entity: Composable, Value: LosslessStringConvertible {
        return try Filter(field: lhs, comparison: EquatableOperator.notEqual, value: rhs)
}

// MARK: - Numeric Filter

/// > Greater than (works only on numbers). Examples: `try \.rating > 79.9`,
public func ><Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter<Entity> where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, comparison: ComparisonOperator.greaterThan, value: String(describing: rhs))
}

/// >= Greater than or equal to (works only on numbers). Examples: `try \.rating >= 80.0`,
public func >=<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter<Entity> where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, comparison: ComparisonOperator.greaterThanOrEqual, value: String(describing: rhs))
}

/// < Less than (works only on numbers). Examples: `try \.rating < 79.9`,
public func <<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter<Entity> where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, comparison: ComparisonOperator.lessThan, value: String(describing: rhs))
}

/// <= Less than or equal to (works only on numbers). Examples: `try \.rating <= 80.0`,
public func <=<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value)
    throws -> Filter<Entity> where Entity: Composable, Value: Numeric {
        return try Filter(field: lhs, comparison: ComparisonOperator.lessThanOrEqual, value: String(describing: rhs))
}

// MARK: - String Filter

infix operator =^*: MultiplicationPrecedence /// = "string"*
infix operator =*&: MultiplicationPrecedence /// = *"string"
infix operator =^*&: MultiplicationPrecedence /// = *"string"*
infix operator ~^*: MultiplicationPrecedence /// ~ "string"*
infix operator ~*&: MultiplicationPrecedence /// ~ *"string"
infix operator ~^*&: MultiplicationPrecedence /// ~ *"string"*

/// = "Your input string"* Prefix: Exact match on the beginning of the string, can end with anything. (Case sensitive).
public func =^*<Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter<Entity> where Entity: Composable {
    return try Filter(field: lhs, comparison: StringOperator.startsWith(.caseSensitive), value: rhs)
}

/// = *"Your input string" Postfix: Exact match at the end of the string, can start with anything. (Case sensitive).
public func =*&<Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter<Entity> where Entity: Composable {
    return try Filter(field: lhs, comparison: StringOperator.endsWith(.caseSensitive), value: rhs)
}

/// = *"Your input string"* Infix Exact match in the middle of the string, can start and end with anything. (Case sensitive).
public func =^*&<Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter<Entity> where Entity: Composable {
    return try Filter(field: lhs, comparison: StringOperator.contains(.caseSensitive), value: rhs)
}

/// ~ "Your input string"* Prefix: Exact match on the beginning of the string, can end with anything. (Case insensitive).
public func ~^*<Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter<Entity> where Entity: Composable {
    return try Filter(field: lhs, comparison: StringOperator.startsWith(.caseInsensitive), value: rhs)
}

/// ~ *"Your input string" Postfix: Exact match at the end of the string, can start with anything. (Case insensitive).
public func ~*&<Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter<Entity> where Entity: Composable {
    return try Filter(field: lhs, comparison: StringOperator.endsWith(.caseInsensitive), value: rhs)
}

/// ~ *"Your input string"* Infix Exact match in the middle of the string, can start and end with anything. (Case insensitive).
public func ~^*&<Entity>(lhs: KeyPath<Entity, String>, rhs: String) throws -> Filter<Entity> where Entity: Composable {
    return try Filter(field: lhs, comparison: StringOperator.contains(.caseInsensitive), value: rhs)
}

// MARK: - Collection Filter

/// [] contains all of these values. Examples: `try \.identifier ~= [3, 4, 5]`,
public func ~=<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: [Value])
    throws -> Filter<Entity> where Entity: Composable, Value: LosslessStringConvertible {
        return try Filter(field: lhs, comparison: CollectionOperator.containsAll, values: rhs)
}

/// () contains at least one of these values. Examples: `try \.identifier *= [3, 4, 5]`,
public func *=<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: [Value])
    throws -> Filter<Entity> where Entity: Composable, Value: LosslessStringConvertible {
        return try Filter(field: lhs, comparison: CollectionOperator.containsAtLeastOne, values: rhs)
}

/// {} contains all of these values exclusively. Examples: `try \.identifier == [3, 4, 5]`,
public func ==<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: [Value])
    throws -> Filter<Entity> where Entity: Composable, Value: LosslessStringConvertible {
        return try Filter(field: lhs, comparison: CollectionOperator.containsExclusively, values: rhs)
}

/// // ![] or !() does not contain all of these values. Examples: `try \.identifier != [3, 4, 5]`,
public func !=<Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: [Value])
    throws -> Filter<Entity> where Entity: Composable, Value: LosslessStringConvertible {
        return try Filter(field: lhs, comparison: CollectionOperator.containsNone, values: rhs)
}
