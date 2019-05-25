// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "libtoken",
    platforms: [
        .iOS(.v12), .watchOS(.v4)
    ],
    products: [
        .library(name: "libtoken", targets: ["libtoken"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "FontAwesome.swift", path: "Sources/FontAwesomeSwift/FontAwesome"),
        .target(name: "libtoken", dependencies: [.target(name: "FontAwesome.swift")]),
        .testTarget(name: "libtokenTests", dependencies: ["libtoken"]),
    ]
)
