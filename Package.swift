// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Apicalypse",
    products: [
        .library(name: "Apicalypse", targets: ["Apicalypse"])
    ],
    targets: [
        .target(name: "Apicalypse", dependencies: []),
        .testTarget(name: "ApicalypseTests", dependencies: ["Apicalypse"])
    ]
)
