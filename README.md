<!-- markdownlint-disable MD002 MD033 MD041 -->
<h1 align="center">
  <a href="https://github.com/markuswntr/apicalypse">
    <img src="https://apicalypse.io/images/logo.png" width="300" max-width="50%" alt="Apicalypse" />
  </a>
  <br>Apicalypse <br>
</h1>

<h4 align="center">
    A simple Swift module for creating Apicalypse queries.
</h4>

<p align="center">
    <a href="https://github.com/markuswntr/apicalypse/releases">
        <img src="https://img.shields.io/github/release/markuswntr/apicalypse.svg" alt="Release Version" />
    </a>
    <a href="https://travis-ci.com/markuswntr/apicalypse">
        <img src="https://travis-ci.com/markuswntr/apicalypse.svg?branch=master" alt="Build Status" />
    </a>
    <a href="https://www.codacy.com/app/markuswntr/apicalypse">
        <img src="https://api.codacy.com/project/badge/Grade/46ed2cb5ee3a43ba9450b56b209f5e25" alt="Codacy" />
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/Swift-4.2-red.svg" alt="Swift Version" />
    </a>
    <a href="https://twitter.com/markuswntr">
        <img src="https://img.shields.io/badge/contact-@markuswntr-5AA9E7.svg" alt="Twitter: @markuswntr" />
    </a>
</p>
<br>
<!-- markdownlint-enable MD033 -->

## Basic example

Say you have your usual-suspect `User` model:

```swift
struct User {
    let id: Int
    let name: String
    let age: Int?
}
```

To use this model as query entity, all you have to do is make `User` conform to `Composable` and link `KeyPath`s to `CodingKey`s

```swift

extension User: Composable {

    static func codingPath(for keyPath: PartialKeyPath<User>) throws -> CodingKey {
        switch keyPath {
        case \User.id: return CodingKeys.id
        case \User.name: return CodingKeys.name
        case \User.age: return CodingKeys.age
        default: throw Error.invalidKeyPath(keyPath)
        }
    }
}
```

Now you can write type-safe Queries on User using KeyPaths:

```swift
let query = try Query(entity: User.self)
    .include(contentsOf: .allFields) // Include all fields of the user, i.e. `id`, `name` and `age`
    .where(\User.age > 20) // Ignore users that are of age 20 or younger
    .exclude(\.age) // Also, exclude age on all users in the response
    .sort(by: \.name, order: .ascending) // Sorted by their name
```

## Advanced example

Given the following struct `Game` and enum `Game.Category`

```swift

struct Game: Composable {

    enum Category: Int, CustomStringConvertible {
        case mainGame = 1
        case expansion
        var description: String {
            return String(rawValue)
        }
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name, category
        case platforms
        case screenshots
    }

    var identifier: UInt64
    var name: String
    var category: Category
    var platforms: [UInt64]
    var screenshots: [UInt64]?

    static func codingPath(for keyPath: PartialKeyPath<Game>) throws -> CodingKey {
        switch keyPath {
        case \Game.identifier: return CodingKeys.identifier
        case \Game.name: return CodingKeys.name
        case \Game.category: return CodingKeys.category
        case \Game.platforms: return CodingKeys.platforms
        case \Game.screenshots: return CodingKeys.screenshots
        default: throw Error.invalidKeyPath(keyPath)
        }
    }
}
```

A more advanced Query (that makes no sense whatsoever, but shows a lot of the built-in features) may look like:

```swift
let query = try Query(entity: Game.self)
    .include(\.name)        // Include name ...
    .include(\.releaseDate) // ... and releaseDate
    .include(\.screenshots) // ... and screenshots
    .include(contentsOf: [\Game.category, \Game.platforms]) // ... and category and platforms

    .exclude(\.releaseDate) // Then exclude releaseDate...
    .exclude(contentsOf: [\Game.platforms]) // .. and platforms

    // Only main games that are on either platform with identifier 9, 6 or 12
    .where(\Game.category == .mainGame && \Game.platforms ~= [9, 6, 12])
    // Only games, that do have screenshots
    .where(\Game.screenshots != nil)
    // Only games where name start with "zelda" (~= means case-insensitive)
    // or have "Mario" somewhere in there name (== means case-sensitive)
    .where(\Game.name ~= "zelda"* || \Game.name == *"Mario"*)

    .sort(by: \.releaseDate, order: .ascending)
    .sort(by: \.category) // `order` will default to .descending
```

> Warning: Multiple `where`-Filter are not (yet) supported. Last `where` will always win.

## Installation

### Swift Package Manager

If you want to use Apicalypse in a project that uses [SPM](https://swift.org/package-manager/),
it's as simple as adding a `dependencies` clause to your `Package.swift`:

``` swift
dependencies: [
    .package(url: "https://github.com/markuswntr/apicalypse.git", from: Version(1, 0, 0))
]
```

> Then `import Apicalypse` wherever necessary.

## Hope you enjoy Apicalypse

For more updates on Apicalypse, and my other open source projects,
follow me on Twitter: [@markuswntr](https://www.twitter.com/markuswntr)

Also make sure to check out [IGDB](https://github.com/markuswntr/igdb), that lets you interact
with the [igdb.com](https://igdb.com) API, to see Apicalypse in action
