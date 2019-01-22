import Foundation

/// <# Description #>
public protocol Operator {

    /// The operator sign of this comparison
    var operation: String { get }

    /// <# Description #>
    func prepare(value: String) -> String
}

/// <# Description #>
public enum EquatableOperator: String, Operator {
    case equal = "="
    case notEqual = "!="

    /// The operator sign of this comparison
    public var operation: String {
        return rawValue
    }

    /// <# Description #>
    public func prepare(value: String) -> String {
        return value // Nothing to compare on single value operations
    }
}

/// <# Description #>
public enum ComparisonOperator: String, Operator {
    case greaterThan = ">"
    case greaterThanOrEqual = ">="
    case lessThan = "<"
    case lessThanOrEqual = "<="

    /// The operator sign of this comparison
    public var operation: String {
        return rawValue
    }

    /// <# Description #>
    public func prepare(value: String) -> String {
        return value // Nothing to compare on single value operations
    }
}

/// <# Description #>
public enum StringOperator: Operator {

    /// <# Description #>
    public enum CaseComparisonMode: String {
        case caseSensitive = "="
        case caseInsensitive = "~"
    }

    case startsWith(CaseComparisonMode)
    case endsWith(CaseComparisonMode)
    case contains(CaseComparisonMode)

    /// The operator sign of this comparison
    public var operation: String {
        switch self {
        case let .startsWith(mode): return mode.rawValue
        case let .endsWith(mode): return mode.rawValue
        case let .contains(mode): return mode.rawValue
        }
    }

    /// <# Description #>
    public func prepare(value: String) -> String {
        switch self {
        case .startsWith: return value + "*"
        case .endsWith: return "*" + value
        case .contains: return "*" + value + "*"
        }
    }
}

/// <# Description #>
public enum CollectionOperator: Operator {
    case containsAll // [] contains all of these values
    case containsExclusively // {} contains all of these values exclusively
    case containsAtLeastOne // () contains at least one of these values
    case containsNone // ![] or !() does not contain all of these values

    /// The operator sign of this comparison
    public var operation: String {
        let operation = (self == .containsNone) ? EquatableOperator.notEqual : .equal
        return operation.rawValue
    }

    /// <# Description #>
    public func prepare(value: String) -> String {
        switch self {
        case .containsAll: return "[" + value + "]"
        case .containsExclusively: return "{" + value + "}"
        case .containsAtLeastOne, .containsNone: return "(" + value + ")"
        }
    }
}
