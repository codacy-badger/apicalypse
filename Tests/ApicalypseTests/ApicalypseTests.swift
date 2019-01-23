import XCTest
@testable import Apicalypse

protocol Identifiable {

    associatedtype Identifier: Numeric

    var identifier: Identifier { get }
}

// MARK: One to One.Identifier

func == <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value.Identifier)
    throws -> Filter where Entity: Composable, Value: Identifiable  {
        return try Filter(property: Entity.codingPath(for: lhs), operator: EquatableOperator.equal, value: String(describing: rhs))
}

func != <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: Value.Identifier)
    throws -> Filter where Entity: Composable, Value: Identifiable  {
        return try Filter(property: Entity.codingPath(for: lhs), operator: EquatableOperator.notEqual, value: String(describing: rhs))
}

// MARK: One to Many.Identifier

func == <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable  {
        return try Filter(property: Entity.codingPath(for: lhs), operator: EquatableOperator.equal, value: String(describing: rhs))
}

func != <Entity, Value>(lhs: KeyPath<Entity, Value>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable  {
        return try Filter(property: Entity.codingPath(for: lhs), operator: EquatableOperator.notEqual, value: String(describing: rhs))
}

// MARK: Many to Many.Identifier

func == <Entity, Value>(lhs: KeyPath<Entity, [Value]>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsAll, value: value)
}

func === <Entity, Value>(lhs: KeyPath<Entity, [Value]>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsExclusively, value: value)
}

func ~= <Entity, Value>(lhs: KeyPath<Entity, [Value]>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsAtLeastOne, value: value)
}

func != <Entity, Value>(lhs: KeyPath<Entity, [Value]>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsNone, value: value)
}

// MARK: Many? to Many.Identifier

func == <Entity, Value>(lhs: KeyPath<Entity, [Value]?>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsAll, value: value)
}

func === <Entity, Value>(lhs: KeyPath<Entity, [Value]?>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsExclusively, value: value)
}

func ~= <Entity, Value>(lhs: KeyPath<Entity, [Value]?>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsAtLeastOne, value: value)
}

func != <Entity, Value>(lhs: KeyPath<Entity, [Value]?>, rhs: [Value.Identifier])
    throws -> Filter where Entity: Composable, Value: Identifiable {
        let value = rhs.map(String.init(describing:)).joined(separator: ",")
        return try Filter(property: Entity.codingPath(for: lhs), operator: CollectionOperator.containsNone, value: value)
}

enum Category: Int, CustomStringConvertible {
    case main
    case addon

    var description: String {
        return String(rawValue)
    }
}

struct Screenshot: Composable, Identifiable {

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case imageUrl = "image_url"
    }

    var identifier: UInt64

    var imageUrl: String

    static func codingPath(for keyPath: PartialKeyPath<Screenshot>) throws -> CodingKey {
        switch keyPath {
        case \Screenshot.identifier: return CodingKeys.identifier
        case \Screenshot.imageUrl: return CodingKeys.imageUrl
        default: XCTFail(); fatalError()
        }
    }
}

struct Platform: Composable, Identifiable {

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case summary
    }

    var identifier: UInt64

    var name: String

    var summary: String?

    static func codingPath(for keyPath: PartialKeyPath<Platform>) throws -> CodingKey {
        switch keyPath {
        case \Platform.identifier: return CodingKeys.identifier
        case \Platform.name: return CodingKeys.name
        case \Platform.summary: return CodingKeys.summary
        default: XCTFail(); fatalError()
        }
    }
}

struct Game: Composable, Identifiable {

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name, category
        case platforms
        case screenshots
        case releaseDate
    }

    var identifier: UInt64

    var name: String

    var category: Category

    var platforms: [Platform]?

    var screenshots: [Screenshot]

    var releaseDate: Date?

    static func codingPath(for keyPath: PartialKeyPath<Game>) throws -> CodingKey {
        switch keyPath {
        case \Game.identifier: return CodingKeys.identifier
        case \Game.name: return CodingKeys.name
        case \Game.category: return CodingKeys.category
        case \Game.platforms: return CodingKeys.platforms
        case \Game.screenshots: return CodingKeys.screenshots
        case \Game.releaseDate: return CodingKeys.releaseDate
        default: XCTFail(); fatalError()
        }
    }
}

final class ApicalypseTests: XCTestCase {
    func testAllNoThrow() {

        XCTAssertNoThrow(try Query(entity: Game.self)
            .include(\.name)
            .include(\.releaseDate)
            .include(\.screenshots)
            .include(contentsOf: [\Game.category, \Game.platforms])
            .include(contentsOf: .allFields)

            .exclude(\.releaseDate)
            .exclude(contentsOf: [\Game.platforms])

            .where(\Game.category == .main && \Game.screenshots ~= [9, 6, 12])
            .where(\Game.platforms != nil)
            .where(\Game.name ~= "zelda"*)

            .sort(by: \.releaseDate, order: .ascending)
            .sort(by: \.category))
    }

    func testSingleInclude() {
        let fields = try? Query(entity: Game.self).include(\.name)
        XCTAssertEqual(fields!.build(), "fields name;")
    }

    func testSingleExclude() {
        let excludes = try? Query(entity: Game.self).exclude(\.name)
        XCTAssertEqual(excludes!.build(), "exclude name;")
    }

    func testCustomStringConvertibleEnumInclude() {
        let include = try? Query(entity: Game.self).include(\.category)
        XCTAssertEqual(include!.build(), "fields category;")
    }

    func testCustomStringConvertibleEnumFilter() {
        let include = try? Query(entity: Game.self).where(\Game.category == .main)
        XCTAssertEqual(include!.build(), "where category = 0;")
    }

    func testJoinedAndFilter() {
        let include = try? Query(entity: Game.self)
            .where(\Game.category == .main && \Game.screenshots ~= [9, 6, 12])
        XCTAssertEqual(include!.build(), "where category = 0 & screenshots = (9,6,12);")
    }

    func testJoinedOrFilter() {
        let include = try? Query(entity: Game.self)
            .where(\Game.category == .main || \Game.screenshots === [9, 6, 12] && \Game.platforms == [18, 21, 4])
        XCTAssertEqual(include!.build(), "where category = 0 | screenshots = {9,6,12} & platforms = [18,21,4];")
    }

    static var allTests = [
        ("testAllNoThrow", testAllNoThrow),
        ("testSingleInclude", testSingleInclude),
        ("testSingleExclude", testSingleExclude),
        ("testCustomStringConvertibleEnumInclude", testCustomStringConvertibleEnumInclude),
        ("testCustomStringConvertibleEnumFilter", testCustomStringConvertibleEnumFilter),
        ("testJoinedAndFilter", testJoinedAndFilter),
        ("testJoinedOrFilter", testJoinedOrFilter),
    ]
}
